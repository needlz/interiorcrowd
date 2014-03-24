class ContestsController < ApplicationController
  
  def step1
    @design_cat = DesignCategory.where("status = ?", DesignCategory::CAT_ACTIVE_STATUS).order('pos ASC')
  end
  
  def step2
    if request.method == "POST"
      if params[:design_cat].present?
        session[:step1] = {}
        session[:step1][:cat_id] = params[:design_cat]
        session[:step1][:other] = params[:other_value]
      else
        flash[:error] = 'Please select atleast one category.'
        redirect_to step1_contests_path
      end        
    end
    @design_space = DesignSpace.where("status = ? AND parent = 0", DesignSpace::SPACE_ACTIVE_STATUS).order('pos ASC')
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
    #@design_space = DesignSpace.where("status = ? AND parent = 0", DesignSpace::SPACE_ACTIVE_STATUS).order('pos ASC')
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
  end
  
  def preview
    if request.method == "POST"
      if params[:step4].present?
        session[:step4]= params[:step4]
      else
        flash[:error] = 'Please fill the required info.'
        redirect_to step3_contests_path
      end        
    end
  end
  
  def step6
    @user = User.new
    if request.method == "POST"
      if params[:step5].present?
        session[:step5] = params[:step5]
        unless session[:step1].present? && session[:step2].present? && session[:step3].present? && session[:step4].present?  
          flash[:error] = 'Please fill the required info.'
          redirect_to step1_contests_path and return if session[:step1].blank?
          redirect_to step2_contests_path and return if session[:step2].blank?
          redirect_to step3_contests_path and return if session[:step3].blank?
          redirect_to step4_contests_path and return if session[:step4].blank? 
        end  
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

end
