class ContestCreationWizard

  attr_reader :active_step_index

  def initialize(action_params, session)
    @params = action_params
    @session = session
    @active_step_index = params[:action][-1, 1]
  end

  def available_design_categories
    DesignCategory.where("status = ?", DesignCategory::CAT_ACTIVE_STATUS).order('pos ASC')
  end

  def available_design_areas
    DesignSpace.where("status = ? AND parent = 0", DesignSpace::SPACE_ACTIVE_STATUS).order('pos ASC')
  end

  private

  attr_reader :params, :session

end