class ContestsController < ApplicationController
  before_filter :check_designer, only: [:respond]

  before_filter :set_creation_wizard, only: [:design_categories, :space_areas, :design_style, :design_space]

  CREATION_STEPS = [
    :design_categories,
    :space_areas,
    :design_style,
    :design_space
  ]

  def index
    @contests = Contest.by_page(params[:page])
  end
  
  def show
    @contest = Contest.find_by_id(params[:id])
    @cr = ContestRequest.find_by_designer_id_and_contest_id(session[:designer_id], params[:id])
    @contest_view = ContestView.new(@contest)
  end
  
  def design_categories
    render
  end

  def save_design_categories
    if params[:design_category].present?
      session[:design_categories] = {}
      session[:design_categories][:cat_id] = params[:design_category]
      session[:design_categories][:other] = params[:other_value]
    end
    redirect_to space_areas_contests_path
  end

  def space_areas
    render
  end

  def save_space_areas
    if params[:design_space].present?
      session[:space_areas] = {}
      session[:space_areas]= params[:design_space]
    end
    redirect_to design_style_contests_path
  end

  def design_style
    render
  end

  def save_design_style
    if params[:design_style].present?
      session[:design_style]= params[:design_style]
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
        redirect_to design_categories_contests_path and return if session[:design_categories].blank?
        redirect_to space_areas_contests_path and return if session[:space_areas].blank?
        redirect_to design_style_contests_path and return if session[:design_style].blank?
        redirect_to design_space_contests_path and return if session[:design_space].blank?
      end
    else
      flash[:error] = I18n.t('contests.creation.errors.required_data_missing')
      redirect_to design_space_contests_path
    end
    redirect_to preview_contests_path
  end

  def preview
    @contest_view = ContestView.new(session)
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
    @contest = Contest.find_by_id(params[:id])
    cr = ContestRequest.find_by_designer_id_and_contest_id(session[:designer_id], params[:id]) 
    redirect_to contest_path if @contest.blank? || cr.present?  
    
    @crequest = ContestRequest.new
    @crequest.designer_id = session[:designer_id]
    @crequest.contest_id = params[:id]   
  end

  private

  def set_creation_wizard
    @creation_wizard = ContestCreationWizard.new(params, session, CREATION_STEPS.index(params[:action].to_sym) + 1)
    @contest_view = ContestView.new(session)
  end

end
