class ContestCreationWizard

  attr_reader :active_step_index

  APPEAL_FEEDBACK = [
    { name: 'Love it!', value: 100 },
    { name: 'Like it!', value: 50 },
    { name: 'Leave it...', value: 0 }
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

  def initialize(options)
    @contest_attributes = options[:contest_attributes]
    @active_step_index = self.class.creation_steps.index(options[:step]) + 1 if options[:step]
  end

  # design categories
  def available_design_categories
    @available_design_categories ||= DesignCategory.available
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

  def budget_options
    placeholder = [I18n.t('contests.space.budget.placeholder'), '']
    [placeholder] + ContestView::CONTEST_DESIGN_BUDGETS.map.with_index { |text, i| [text, i] }
  end

  def budget_plans
    BudgetPlan.all.map { |plan| PackageView.new(plan) }
  end

  def self.card_type_options
    ContestCreationWizard::CARD_TYPES.map do |type|
      [I18n.t("client_center.profile.labels.card_types.#{ type }"), type]
    end
  end

  private

  attr_reader :contest_attributes

end
