class ContestsController < ApplicationController
  before_filter :check_designer, only: [:respond]
  before_filter :check_client, only: [:index, :payment_details]

  before_filter :set_creation_wizard, only: [:design_brief, :design_style, :design_space, :preview, :payment_details]
  before_filter :set_contest, only: [:show, :respond, :option, :update, :download_all_images_url]
  before_filter :set_client, only: [:index, :show, :payment_summary]

  def show
    return raise_404 unless current_user.see_contest?(@contest)

    @navigation = Navigation::ClientCenter.new(:entries)
    @entries_page = EntriesPage.new(
      contest: @contest,
      view: params[:view],
      answer: params[:answer],
      page: params[:page],
      current_user: current_user,
      view_context: view_context
    )

    if @entries_page.show_submissions? || @entries_page.won_contest_request
      render 'clients/client_center/entries'
    else
      render 'clients/client_center/entries_invitations'
    end
  end

  def index
    @current_contests = @client.contests.in_progress
    @completed_contests = @client.contests.inactive
  end
  
  def design_brief
    render
  end

  def save_design_brief
    session[:design_brief] = params[:design_brief] if params[:design_brief].present?
    redirect_to design_style_contests_path
  end

  def design_style
    render
  end

  def save_design_style
    session[:design_style] = params[:design_style] if params[:design_style].present?
    redirect_to design_space_contests_path
  end

  def design_space
    @budget_option = session[:design_space].present? ? session[:design_space][:f_budget] : ''
  end

  def save_design_space
    session[:design_space] = params[:design_space] if params[:design_space].present?
    redirect_to preview_contests_path
  end

  def preview
    return if redirect_to_uncompleted_step(ContestCreationWizard.creation_steps - [:preview])
    @contest_view = ContestView.new(contest_attributes: session.to_hash)
  end

  def save_preview
    return if redirect_to_uncompleted_step(ContestCreationWizard.creation_steps - [:preview])
    if params[:preview].present?
      session[:preview] = params[:preview]
      on_previewed
    else
      flash[:error] = I18n.t('contests.creation.errors.required_data_missing')
      redirect_to preview_contests_path and return
    end
  end

  def account_creation
    return if redirect_to_uncompleted_step(ContestCreationWizard.creation_steps)
    @client = Client.new
  end

  def payment_details
    return render_404 unless Settings.payment_enabled
    @client = current_user
    begin
      @contest = @client.contests.find(params[:id])
      return redirect_to payment_summary_contests_path(id: @contest.id) if @contest.payed?
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    @client_payment = ClientPayment.new
    @shared_card_view = CreditCardView.new(nil)
    @show_cards_manager = @client.credit_cards.present?
    ActiveRecord::Associations::Preloader.new.preload(@client, :primary_card)
    @card_views = @client.credit_cards.from_newer_to_older.map{ |credit_card| CreditCardView.new(credit_card) }
    @credit_card = @client.credit_cards.new
  end

  def payment_summary
    return render_404 unless Settings.payment_enabled
    begin
      @contest = @client.contests.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    payment = @contest.client_payment
    return raise_404 ArgumentError.new('contest not payed') unless payment
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
      render json: { msg: "Upload Failed", error: @image.error }
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
    ContestCreationWizard.creation_steps.each do |creation_step|
      session[creation_step] = params[creation_step] if params[creation_step]
    end
    render nothing: true
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
    @creation_wizard = ContestCreationWizard.new(contest_attributes: ContestOptions.new(session.to_hash).contest,
                                                 step: params[:action].to_sym,
                                                 current_user: current_user)
    @contest_view = ContestView.new(contest_attributes: session.to_hash)
    if current_user.client?
      @navigation = Navigation::ClientCenter.new(:entries)
      @client = current_user
    end
  end

  def set_contest
    @contest = Contest.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    raise_404(e)
  end

  def uncomplete_step_path(validated_steps)
    uncomplete_step = validated_steps.detect { |step| ContestOptions.new(session.to_hash).uncompleted_chapter == step }
    ContestCreationWizard.creation_steps_paths[uncomplete_step] if uncomplete_step
  end

  def on_previewed
    return redirect_to account_creation_contests_path unless current_user.client?

    @client = current_user
    contest_creation = ContestCreation.new(client_id: @client.id, contest_params: session)
    contest_creation.on_success do
      clear_creation_storage
    end
    contest_creation.perform

    if Settings.payment_enabled
      redirect_to payment_details_contests_path(id: contest_creation.contest.id)
    else
      redirect_to client_center_entry_path(id: contest_creation.contest.id)
    end
  end

  private

end
