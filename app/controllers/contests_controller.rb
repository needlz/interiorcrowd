class ContestsController < ApplicationController
  before_filter :check_designer, only: [:respond]

  before_filter :set_creation_wizard, only: [:design_brief, :design_style, :design_space, :preview]
  before_filter :set_contest, only: [:show, :respond, :option]

  CREATION_STEPS = [
    :design_brief,
    :design_style,
    :design_space,
    :preview
  ]

  def index
    @contests = Contest.by_page(params[:page])
  end
  
  def show
    @request = ContestRequest.find_by_designer_id_and_contest_id(session[:designer_id], @contest.id)
    @contest_view = ContestView.new(@contest)
  end
  
  def design_brief
    render
  end

  def save_design_brief
    if params[:design_category].present?
      session[:design_brief] = {}
      session[:design_brief][:design_category] = params[:design_category]
      session[:design_brief][:design_area]= params[:design_area]
    end
    redirect_to design_style_contests_path
  end

  def design_style
    render
  end

  def save_design_style
    if params[:design_style].present?
      session[:design_style] = params[:design_style]
    end
    redirect_to design_space_contests_path
  end

  def design_space
    @budget_option = session[:design_space].present? ? session[:design_space][:f_budget] : ''
  end

  def save_design_space
    if params[:design_space].present?
      session[:design_space] = params[:design_space]
      unless CREATION_STEPS.all? { |step| session[step].present? }
        flash[:error] = I18n.t('contests.creation.errors.required_data_missing')
        redirect_to uncomplete_step_path and return if uncomplete_step_path
      end
    else
      flash[:error] = I18n.t('contests.creation.errors.required_data_missing')
      redirect_to design_space_contests_path
    end
    redirect_to preview_contests_path
  end

  def preview
    redirect_to uncomplete_step_path and return if uncomplete_step_path
    @contest_view = ContestView.new(session.to_hash)
  end

  def save_preview
    @client = Client.new
    if params[:preview].present?
      session[:preview] = params[:preview]
      render 'contests/account_creation'
    else
      flash[:error] = I18n.t('contests.creation.errors.required_data_missing')
      redirect_to preview_contests_path and return
    end
  end

  def account_creation
    @client = Client.new
    redirect_to preview_contests_path and return
  end

  def upload
    params[:image] = {}
    params[:image][:image] = params[:photo]
    params.require(:image).permit(:image)
    
    @image = Image.new(params[:image])
    
    if @image.save
      render json: @image.image.url(:thumb)
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
    @creation_wizard = ContestCreationWizard.new(action_params: params, action_session: session, step_index: 0)
    @contest_view = ContestView.new(@contest)
    option = params[:option]
    render partial: "contests/options/#{ option }_options"
  end

  private

  def set_creation_wizard
    @creation_wizard = ContestCreationWizard.new(action_params: params,
                                                 action_session: session,
                                                 step_index: CREATION_STEPS.index(params[:action].to_sym) + 1)
    @contest_view = ContestView.new(session.to_hash)
  end

  def set_contest
    @contest = Contest.find_by_id(params[:id])
  end

  def uncomplete_step_path
    return design_brief_contests_path if session[:design_brief].blank?
    return design_style_contests_path if session[:design_style].blank?
    design_space_contests_path if session[:design_space].blank?
  end
end
