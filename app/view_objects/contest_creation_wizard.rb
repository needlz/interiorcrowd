class ContestCreationWizard

  attr_reader :active_step_index

  APPEAL_FEEDBACK = [
    { name: :love_it, value: 100 },
    { name: :like_it, value: 50 },
    { name: :leave_it, value: 0 }
  ]

  def self.creation_steps_paths
    urls_helper = Rails.application.routes.url_helpers
    @creation_steps_paths ||=
      { design_brief: urls_helper.design_brief_contests_path,
        design_style: urls_helper.design_style_contests_path,
        design_space: urls_helper.design_space_contests_path,
        preview: urls_helper.preview_contests_path }
  end

  def self.creation_steps
    creation_steps_paths.keys
  end

  def self.budget_plans
    BudgetPlan.all.map { |plan| PackageView.new(plan) }
  end

  def self.uncomplete_step_path(contest_options, validated_steps)
    uncomplete_step = validated_steps.detect { |step| contest_options.uncompleted_chapter == step }
    creation_steps_paths[uncomplete_step] if uncomplete_step
  end

  def self.finished_step?(contest, index)
    case index
      when 0
        contest.design_category_id.present? && contest.design_spaces.present?
      when 1
        contest.desirable_colors.present? && contest.contests_appeals.count == Appeal.count
      when 2
        contest.space_budget.present?
      when 3
        contest.project_name.present? && contest.budget_plan.present?
    end
  end

  def self.unfinished_step(contest)
    (0..(steps_count - 1)).each do |step|
      return step unless finished_step?(contest, step)
    end
    nil
  end

  def self.incomplete_step_path(contest)
    incomplete_step = creation_steps[unfinished_step(contest).to_i]
    RenderingHelper.new.send("#{ incomplete_step }_contest_path", id: contest.id)
  end

  def self.steps_count
    4
  end

  def initialize(options)
    @current_user = options[:current_user]
    @contest_attributes = options[:contest_attributes]
    @active_step_index = self.class.creation_steps.index(options[:step]) if options[:step]
  end

  # design categories
  def available_design_categories
    @available_design_categories ||= DesignCategory.available.map { |category| DesignCategoryView.new(category) }
  end

  def design_categories_checkboxes
    return @design_categories_checkboxes if @design_categories_checkboxes
    checkboxes_array = available_design_categories.map do |category|
      [category.id, contest_attributes.try(:[], :design_category_id) == category.id]
    end
    @design_categories_checkboxes = Hash[checkboxes_array]
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

  def top_level_areas
    @top_level_areas ||= available_design_areas.top_level.includes(:children)
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
    APPEAL_FEEDBACK
  end

  def pending_contest_exists?
    return false unless current_user && current_user.client? && current_user.contests.exists?
    current_user.contests.where(status: Contest::COMPLETED_NON_FINISHED_STATUSES).exists?
  end

  def show_sign_up_suggestion?
    !current_user.client?
  end

  private

  attr_reader :contest_attributes
  attr_reader :current_user

end
