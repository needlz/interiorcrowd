class ContestCreationWizard

  attr_reader :active_step_index

  def initialize(action_params, action_session)
    @params = action_params
    @session = action_session
    @active_step_index = params[:action][-1, 1].to_i
  end

  # design categories
  def available_design_categories
    @available_design_categories ||= DesignCategory.where(status: DesignCategory::CAT_ACTIVE_STATUS).order('pos ASC')
  end

  def design_categories_checkboxes
    return @design_categories_checkboxes if @design_categories_checkboxes
    @design_categories_checkboxes = {}
    available_design_categories.each do |category|
      @design_categories_checkboxes[category.id] = session[:step1] && session[:step1][:cat_id].include?(category.id.to_s)
    end
    @design_categories_checkboxes
  end

  def other_category_text
    @other_category_text ||= session[:step1][:other] if session[:step1].present?
  end


  # design areas
  def available_design_areas
    @available_design_areas ||= DesignSpace.where(status: DesignSpace::SPACE_ACTIVE_STATUS).order('pos ASC')
  end

  def design_areas_checkboxes
    return @design_areas_checkboxes if @design_areas_checkboxes
    @design_areas_checkboxes = {}
    available_design_areas.each do |area|
      @design_areas_checkboxes[area.id] = session[:step2].present? && session[:step2].include?(area.id.to_s)
    end
    @design_areas_checkboxes
  end

  private

  attr_reader :params, :session

end