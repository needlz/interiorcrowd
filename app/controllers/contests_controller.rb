class ContestsController < ApplicationController
  before_filter :check_designer, only: [:respond]

  before_filter :set_creation_wizard, only: [:design_brief, :design_style, :design_space, :preview]
  before_filter :set_contest, only: [:show, :respond, :option, :update, :download_all_images_url]

  def show
    @request = ContestRequest.find_by_designer_id_and_contest_id(session[:designer_id], @contest.id)
    @contest_view = ContestView.new(contest_attributes: @contest)
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
    @client = current_client
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
  
  def respond
    request = ContestRequest.find_by_designer_id_and_contest_id(session[:designer_id], @contest.id)
    redirect_to contest_path if @contest.blank? || request.present?

    @crequest = ContestRequest.new
    @crequest.designer_id = session[:designer_id]
    @crequest.contest_id = params[:id]
  end

  def option
    @creation_wizard = ContestCreationWizard.new(contest_attributes: @contest)
    @contest_view = ContestView.new(contest_attributes: @contest)
    option = params[:option]
    render partial: 'contests/options/attribute_form', locals: { fields_partial: "contests/options/#{ option }_options",
                                                                 option: option }
  end

  def update
    options = ContestOptions.new(params.with_indifferent_access)
    contest_updater = ContestUpdater.new(@contest, options)
    contest_updater.perform

    if params[:pictures_dimension]
      redirect_to entries_client_center_index_path
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
                                                 step: params[:action].to_sym)
    @contest_view = ContestView.new(contest_attributes: session.to_hash)
  end

  def set_contest
    @contest = Contest.find(params[:id])
  end

  def uncomplete_step_path(validated_steps)
    uncomplete_step = validated_steps.detect { |step| ContestOptions.new(session.to_hash).uncompleted_chapter == step }
    ContestCreationWizard.creation_steps_paths[uncomplete_step] if uncomplete_step
  end

  def current_client
    return current_user if current_user.client?
    Client.new
  end

  def on_previewed
    return redirect_to account_creation_contests_path unless current_user.client?

    contest_creation = ContestCreation.new(@client.id, session)
    contest_creation.on_success do
      clear_creation_storage
    end
    contest_creation.perform

    redirect_to entries_client_center_index_path
  end

end
