class ContestsController < ApplicationController
  before_filter :check_designer, :only => [:respond]

  before_filter :set_creation_wizard, only: [:step1, :step2, :step3, :step4]
  before_filter :set_appeal_scales, only: [:step3, :preview]
  before_filter :set_dimensions, only: [:step4, :preview]

  def index
    @contests = Contest.by_page(params[:page])
  end
  
  def show
    @contest = Contest.find_by_id(params[:id])
    @cr = ContestRequest.find_by_designer_id_and_contest_id(session[:designer_id], params[:id])
    @dimensions = SpaceDimension.from(@contest)
    @appeal_scales = AppealScale.from(@contest)
    @categories = DesignCategory.where("id IN (?)", @contest.cd_cat.split(',')).order(:pos)
    @design_areas = DesignSpace.where("id IN (?)", @contest.cd_space.split(',')).order(:pos)
    @favorited_colors = @contest.cd_fav_color
    @avoided_colors = @contest.cd_refrain_color
    @examples = @contest.cd_style_ex_images.split(',')
    @links = @contest.cd_style_links
    @space_pictures = @contest.cd_space_images.split(',').map { |image_id| Image.find(image_id).image.url(:medium) }
    @budget = Contest::CONTEST_DESIGN_BUDGETS[@contest.cd_space_budget.to_i]
    @comment = @contest.feedback
  end
  
  def step1
    render
  end
  
  def step2
    if request.method == "POST"
      if params[:design_category].present?
        session[:step1] = {}
        session[:step1][:cat_id] = params[:design_category]
        session[:step1][:other] = params[:other_value]
      else
        flash[:error] = 'Please select atleast one category.'
        redirect_to step1_contests_path
      end        
    end
  end
  
  def step3
    if request.method == "POST"
      if params[:design_space].present?
        session[:step2] = {}
        session[:step2]= params[:design_space]
      else
        flash[:error] = 'Please select atleast one area.'
        redirect_to step2_contests_path
      end
    end
  end
  
  def step4
    if request.method == "POST"
      if params[:step3].present?
        session[:step3]= params[:step3]
      else
        flash[:error] = 'Please fill the required info.'
        redirect_to step3_contests_path
      end        
    end
    @budget_option = session[:step4].present? ? session[:step4][:f_budget] : ''
    @feedback = session[:step4].present? ? session[:step4][:feedback] : ''
  end
  
  def preview
    if request.method == "POST"
      if params[:step4].present?
        session[:step4]= params[:step4]
        unless session[:step1].present? && session[:step2].present? && session[:step3].present? && session[:step4].present?  
          flash[:error] = 'Please fill the required info.'
          redirect_to step1_contests_path and return if session[:step1].blank?
          redirect_to step2_contests_path and return if session[:step2].blank?
          redirect_to step3_contests_path and return if session[:step3].blank?
          redirect_to step4_contests_path and return if session[:step4].blank? 
        end  
      else
        flash[:error] = 'Please fill the required info.'
        redirect_to step4_contests_path
      end        
    end
    @categories = DesignCategory.where("id IN (?)", session[:step1][:cat_id]).order(:pos)
    @design_areas = DesignSpace.where("id IN (?)", session[:step2]).order(:pos)
    @favorited_colors = session[:step3][:fav_color]
    @avoided_colors = session[:step3][:refrain_color]
    @examples = session[:step3][:document].split(',')
    @links = session[:step3][:ex_links]
    @space_pictures = session[:step4][:document].split(',')
    @budget = Contest::CONTEST_DESIGN_BUDGETS[session[:step4][:f_budget].to_i]
    @comment = session[:step4][:feedback]
  end
  
  def step6
    @client = Client.new
    if request.method == "POST"
      if params[:step5].present?
        session[:step5] = params[:step5]
      else
        flash[:error] = 'Please fill the required info.'
        redirect_to preview_contests_path and return
      end        
    else
      redirect_to preview_contests_path and return
    end
  end
  
  
  def upload
    params[:image] = {}
    params[:image][:image] = params[:photo]
    params.require(:image).permit(:image)
    
    @image = Image.new(params[:image])
    
    if @image.save
        render :json =>  @image.image.url(:thumb)
    else
        render :json => {:msg => "Upload Failed", :error => @image.error}
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
    @creation_wizard = ContestCreationWizard.new(params, session)
  end

  def set_appeal_scales
    appeal_values = session[:step3]
    @appeal_scales = AppealScale.from(appeal_values)
  end

  def set_dimensions
    @dimensions = SpaceDimension.from(session[:step4])
  end

end
