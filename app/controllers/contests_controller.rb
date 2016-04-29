class ContestsController < ApplicationController
  before_filter :check_designer, only: [:respond]

  before_filter :set_client, only: [:index, :payment_summary, :invite_designers, :payment_details]
  before_filter :set_contest, only: [:respond, :option, :update, :download_all_images_url, :invite_designers,
                                     :image_items]
  before_filter :set_creation_wizard, :set_save_path, only: ContestCreationWizard.creation_steps

  [:design_brief, :design_style, :design_space].each do |action|
    define_method action do
      development_scenarios do
        [
          { scenario_class: FillContestCreationHelper,
            scenario_method: :create_full,
            name: 'Fill all steps with brief completed' },
          { scenario_class: FillContestCreationHelper,
            scenario_method: :create_with_brief_pending,
            name: 'Fill all steps with brief pending' }
        ]
      end
      render
    end

    define_method "save_#{ action }" do
      save_intake_form_step(action)
    end
  end

  def show
    @contest = Contest.find_by_id(params[:id])
    unless @contest
      @contest = ContestRequest.find_by_id(params[:id]).try(:contest)
      return redirect_to client_center_entry_path(@contest.id) if @contest
    end
    raise_404 unless @contest
    unless current_user.can_see_contest?(@contest, cookies)
      if current_user.client?
        raise_404
      else
        return redirect_to(client_login_sessions_path)
      end
    end
    return redirect_to(payment_details_contests_path(id: @contest.id)) if payment_details_to_be_entered?

    @entries_page = EntriesPage.new(
      contest: @contest,
      view: (params[:view].to_i if params[:view]),
      answer: params[:answer],
      pagination_options: params,
      current_user: current_user,
      view_context: view_context
    )

    @setup_viglink = @entries_page.phases_stripe.active_phase == :final_design

    if current_user.client?
      @setup_viglink = true
      @client = current_user
      @breadcrumbs = Breadcrumbs::Client.new(self).my_contests.contest(@contest)
      @navigation = "Navigation::ClientCenter::#{ @contest.status.camelize }".constantize.new(:entries, contest: @contest)
      TrackContestRequestVisit.perform(@entries_page.won_contest_request) if @entries_page.won_contest_request
    end

    if @entries_page.show_submissions? || @entries_page.won_contest_request || !(@contest.client == current_user)
      render 'clients/client_center/entries'
    else
      render 'clients/client_center/entries_invitations'
    end
  end

  def index
    @show_contest_creation_button = ClientContestCreationPolicy.for_client(@client).create_contest.can?
    @current_contests = ContestsColumns.new(@client.contests.in_progress.includes(:design_category, :preferred_retailers, :design_spaces, :contests_appeals))
    @completed_contests = ContestsColumns.new(@client.contests.inactive.includes(:design_category, :preferred_retailers, :design_spaces, :contests_appeals))
  end

  def preview
    return if redirect_to_uncompleted_step(ContestCreationWizard.creation_steps - [:preview])
    @contest_view = ContestView.new(contest_attributes: session.to_hash)
  end

  def save_preview
    if params[:id]
      return unless set_client
      begin
        @contest = Contest.find(params[:id])
        return redirect_to brief_contest_path(id: @contest.id) if @contest.completed?
        @contest
      rescue ActiveRecord::RecordNotFound => e
        return raise_404(e)
      end
    end
    unless @contest
      return if redirect_to_uncompleted_step(ContestCreationWizard.creation_steps - [:preview])
    end
    if params[:preview].present?
      if @contest
        update_contest_attributes(@contest)
      else
        session[:preview] = params[:preview]
      end
      on_previewed
    else
      flash[:error] = I18n.t('contests.creation.errors.required_data_missing')
      redirect_to preview_contests_path
    end
  end

  def save_intake_form_step(action)
    next_step_index = ContestCreationWizard.creation_steps.find_index(action) + 1
    next_step = ContestCreationWizard.creation_steps[next_step_index]

    if params[:id]
      incomplete_contest = fetch_incomplete_contest(params[:id])
      return render_404 unless incomplete_contest
      update_contest_attributes(incomplete_contest)
      return redirect_to(controller: 'contests', action: next_step, id: incomplete_contest.id)
    else
      session[action] = params[action] if params[action].present?
    end

    incomplete_contest = fetch_incomplete_contest
    if incomplete_contest
      redirect_to(controller: 'contests', action: action, id: incomplete_contest.id)
    else
      if current_user.client?
        contest_creation = ContestCreation.new(client_id: current_user.id, contest_params: session, make_complete: false)
        contest_creation.on_success do
          clear_creation_storage
        end
        contest_creation.perform
        contest = contest_creation.contest
        redirect_to(controller: 'contests', action: next_step, id: contest.id)
      else
        redirect_to(controller: 'contests', action: next_step)
      end
    end
  end

  def account_creation
    return if redirect_to_uncompleted_step(ContestCreationWizard.creation_steps)
    @client = Client.new
  end

  def payment_details
    @client = current_user
    begin
      @contest = @client.contests.find(params[:id])
      return redirect_to payment_summary_contests_path(id: @contest.id) if @contest.paid? && Settings.automatic_payment
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    @client_payment = ClientPayment.new
    @show_cards_manager = @client.credit_cards.present?
    ActiveRecord::Associations::Preloader.new.preload(@client, :primary_card)
    @card_views = @client.credit_cards.from_newer_to_older.map{ |credit_card| CreditCardView.new(credit_card) }
    @credit_card = @client.credit_cards.new
    create_creation_wizard(@contest)
  end

  def payment_summary
    begin
      @contest = @client.contests.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    payment = @contest.client_payment
    return raise_404 ArgumentError.new('contest not paid') unless payment
    @payment_view = PaymentView.new(payment)
  end

  def upload
    params[:image] = {}
    params[:image][:image] = params[:photo]
    params.require(:image).permit(:image)
    
    @image = Image.new(params[:image])
    
    if @image.save
      render json: @image.medium_size_url
    else
      render json: { msg: 'Upload Failed', error: @image.error }
    end
  end

  def option
    @creation_wizard = ContestCreationWizard.new(contest_attributes: @contest)
    @contest_view = ContestView.new(contest_attributes: @contest)
    option = params[:option]
    render partial: 'contests/options/attribute_form',
           locals: { fields_partial: "contests/options/#{ option }_options",
                     option: option }
  end

  def update
    options = ContestOptions.new(params.with_indifferent_access)
    contest_updater = ContestUpdater.new(@contest, options)
    contest_updater.perform

    if params[:pictures_dimension]
      redirect_to client_center_entry_path(id: @contest.id)
    else
      @creation_wizard = ContestCreationWizard.new(contest_attributes: @contest)
      @contest_view = ContestView.new(contest_attributes: @contest)
      render partial: "contests/previews/#{ params[:option] }_preview"
    end
  end

  def download_all_images_url
    images_type = params[:type]
    raise_404 unless images_type

    archive_path = ImagesArchivationMonitor.request_archive(@contest, images_type)
    return render(json: archive_path.to_json) if archive_path
    render nothing: true
  end

  def save_intake_form
    if params[:id]
      incomplete_contest = fetch_incomplete_contest(params[:id])
      return render(json: { saved: false }) unless incomplete_contest
      update_contest_attributes(incomplete_contest)
    else
      ContestCreationWizard.creation_steps.each do |creation_step|
        session[creation_step] = params[creation_step] if params[creation_step]
      end
    end
    render json: { saved: true }
  end

  def invite_designers
    return raise_404 unless ContestPolicies.new(@contest).invite_designers_page_accessible?
    @navigation = "Navigation::ClientCenter::#{ @contest.status.camelize }".constantize.new(:entries, contest: @contest)
    @designers = Designer.active.includes(portfolio: [:personal_picture]).all.map do |designer|
      DesignerView.new(designer)
    end
  end

  def image_items
    unless current_user.can_see_contest?(@contest, cookies)
      if current_user.client?
        raise_404
      else
        return redirect_to(client_login_sessions_path)
      end
    end

    @entries_page = EntriesPage.new(
      contest: @contest,
      view: params[:view],
      answer: params[:answer],
      pagination_options: params,
      current_user: current_user,
      view_context: view_context
    )

    render @entries_page.entries_concept_board_page.paginated_image_items_partial
  end

  private

  def redirect_to_uncompleted_step(validated_steps)
    uncompleted_step_path = uncomplete_step_path(validated_steps)
    return unless uncompleted_step_path
    flash[:error] = I18n.t('contests.creation.errors.required_data_missing')
    redirect_to uncompleted_step_path
    true
  end

  def set_creation_wizard
    set_client_navigation
    return unless set_creation_wizard_source
    create_creation_wizard(@contest_attributes)
  end

  def set_creation_wizard_source
    @contest_attributes =
      if params[:id]
        raise_404 and return false unless @client
        begin
          @contest = Contest.find(params[:id])
          redirect_to brief_contest_path(id: @contest.id) and return false if @contest.completed?
          @contest
        rescue ActiveRecord::RecordNotFound => e
          raise_404(e) and return false
        end
      else
        incomplete_contest = fetch_incomplete_contest
        if incomplete_contest
          redirect_to(controller: 'contests', action: action_name, id: incomplete_contest.id) and return false
        end
        session.to_hash
      end
  end

  def set_client_navigation
    if current_user.client?
      @navigation = Navigation::ClientCenter::Base.new(:entries)
      @client = current_user
    end
  end

  def create_creation_wizard(source)
    @creation_wizard = ContestCreationWizard.new(contest_attributes: to_contest_options(source),
                                                 step: params[:action].to_sym,
                                                 current_user: current_user)
    @contest_view = ContestView.new(contest_attributes: source)
  end

  def set_contest
    @contest = Contest.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    raise_404(e)
  end

  def to_contest_options(contest_attributes)
    if contest_attributes.kind_of?(Hash)
      ContestOptions.new(contest_attributes).contest
    else
      contest_attributes
    end
  end

  def uncomplete_step_path(validated_steps)
    ContestCreationWizard.uncomplete_step_path(ContestOptions.new(@contest || session.to_hash), validated_steps)
  end

  def on_previewed
    return redirect_to account_creation_contests_path unless current_user.client?

    @client = current_user
    contest =
      if @contest
        complete_contest = CompleteContest.new(@contest)
        complete_contest.perform
        @contest
      else
        contest_creation = ContestCreation.new(client_id: @client.id, contest_params: session, make_complete: true)
        contest_creation.on_success do
          clear_creation_storage
        end
        contest_creation.perform
        contest_creation.contest
      end

    redirect_to payment_details_contests_path(id: contest.id)
  end

  def payment_details_to_be_entered?
    if Settings.automatic_payment
      !(@contest.paid? || billing_details_provided? || @contest.published?)
    else
      !billing_details_provided?
    end
  end

  def billing_details_provided?
    @contest.client.primary_card.present?
  end

  def fetch_incomplete_contest(contest_id = nil)
    if contest_id
      current_user.contests.incomplete.find_by_id(contest_id)
    else
      current_user.client? && current_user.contests.incomplete.first
    end
  end

  def set_save_path
    @save_path = @contest ? send("save_#{ action_name }_contest_path", id: @contest.id) : send("save_#{ action_name }_contests_path")
  end

  def update_contest_attributes(contest)
    contest_options = ContestOptions.new(params.with_indifferent_access)
    incomplete_contest_updater = ContestUpdater.new(contest, contest_options)
    incomplete_contest_updater.perform
  end

end
