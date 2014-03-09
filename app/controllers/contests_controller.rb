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
      end        
    end
    #@design_space = DesignSpace.where("status = ? AND parent = 0", DesignSpace::SPACE_ACTIVE_STATUS).order('pos ASC')
  end
  
  def step4
    
  end
  
  def preview
    
  end

end
