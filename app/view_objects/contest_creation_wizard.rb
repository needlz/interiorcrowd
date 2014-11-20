class ContestCreationWizard

  attr_reader :active_step_index

  APPEAL_FEEDBACK = [
    { name: 'Love it!', value: 100 },
    { name: 'Like it!', value: 50 },
    { name: 'Leave it...', value: 0 }
  ]

  def initialize(action_params, action_session, step_index)
    @params = action_params
    @session = action_session
    @active_step_index = step_index
  end

  # design categories
  def available_design_categories
    @available_design_categories ||= DesignCategory.available
  end

  def design_categories_checkboxes
    return @design_categories_checkboxes if @design_categories_checkboxes
    @design_categories_checkboxes = {}
    available_design_categories.each do |category|
      @design_categories_checkboxes[category.id] = session[:design_brief].try(:[], :design_category) && session[:design_brief][:design_category].include?(category.id.to_s)
    end
    @design_categories_checkboxes
  end

  def breadcrumb_class(step_index)
    return 'previous' if step_index < active_step_index
    return 'active' if step_index == active_step_index
    'next'
  end

  # design areas
  def available_design_areas
    @available_design_areas ||= DesignSpace.available
  end

  def available_areas
    DesignSpace.available.top_level.includes(:children).map do |area|
      { id: area.id, name: area.name, children: area.children }
    end
  end

  def available_designer_levels
    DesignerLevel.all.order(:id)
  end

  def available_appeal_feedback
    APPEAL_FEEDBACK.map do |appeal_feedback|
      [appeal_feedback[:name], appeal_feedback[:value]]
    end
  end

  def budget_options
    Contest::CONTEST_DESIGN_BUDGETS.invert
  end

  private

  attr_reader :params, :session

end