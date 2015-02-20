class ContestView

  CONTEST_DESIGN_BUDGETS = [I18n.t('contests.space.budget.placeholder'), '$0 - $200', '$201 - $500', '$501 - $1000', '$1001 - $1500', '$1501 - $2500',
                             '$2501 - $3500', '$3501 - $5000', '$5001 - $7500', '$7501 - $10000', '$10000 +' ]

  ACCOMMODATION_ATTRIBUTES = [:accommodate_children, :accommodate_pets]

  attr_reader :dimensions, :appeal_scales, :category, :design_area, :desirable_colors, :undesirable_colors, :examples,
              :links, :space_pictures, :budget, :feedback, :budget_plan, :name, :designer_level, :example_ids,
              :space_pictures_ids, :additional_preferences, :have_space_views_details, :have_examples,
              :space_budget_value, :retailers, :other_retailers

  ContestAdditionalPreference.preferences.map do |preference|
    attr_reader preference
  end

  ACCOMMODATION_ATTRIBUTES.each do |attribute|
    attr_reader attribute
  end

  EDITABLE_ATTRIBUTES = [
    :category, :area, :design_profile, :desirable_colors, :undesirable_colors,
    :example_pictures, :budget, :example_links, :space_pictures, :space_dimensions, :feedback,
    :design_package, :additional_preferences, :preferences_retailers, :element_to_avoid,
    :entertaining, :durability] + ACCOMMODATION_ATTRIBUTES

  CONTEST_PREVIEW_ATTRIBUTES = [
    :name, :design_knowledge, :design_style, :desirable_colors, :undesirable_colors, :example_pictures,
    :example_links, :space_pictures, :space_dimensions, :floorplan, :budget, :feedback]

  LEVELS = {
    2 => :very,
    1 => :somewhat,
    0 => :not
  }

  def initialize(options)
    if options.kind_of?(Hash)
      initialize_from_options(HashWithIndifferentAccess.new(options))
    else
      initialize_from_contest(options)
    end
    set_have_space_views_details
    set_have_examples
  end

  def top_level_area_active?(area)
    design_area == area || design_area.try(:parent) == area
  end

  def conditional_block_radio_button_active?(is_block_visible, button_value)
    active_button_value = is_block_visible ? 'yes' : 'no'
    button_value == active_button_value
  end

  def package_selected?(package_id)
    package_id == @budget_plan.to_i
  end

  def design_styles
    styles = appeal_scales.map do |appeal|
      if appeal.value == ContestCreationWizard::APPEAL_FEEDBACK.first[:value]
        appeal.first_name
      elsif appeal.value == ContestCreationWizard::APPEAL_FEEDBACK.last[:value]
        appeal.second_name
      end
    end
    styles.compact.join(', ')
  end

  def preferred_retailers
    @retailers.select { |retailer| retailer[:value] }
  end

  def retailers_string
    return 'None' if preferred_retailers.blank? && other_retailers.blank?
    retailers_list = preferred_retailers.map { |retailer| self.class.retailer_name(retailer[:name]) }
    retailers_list << other_retailers if other_retailers.present?
    "(#{ retailers_list.join(', ') })"
  end

  def self.retailer_name(retailer)
    I18n.t("client_center.entries.preferences_retailers.#{ retailer }")
  end

  def elements_to_avoid
    return 'None' if @elements_to_avoid.blank?
    ERB::Util.html_escape(@elements_to_avoid).split("\n").join('<br>')
  end

  def options_level(level)
    I18n.t("client_center.entries.option_levels.#{ LEVELS[level.to_i] }")
  end

  def entertaining
    options_level(@entertaining)
  end

  def durability
    options_level(@durability)
  end

  private

  def initialize_from_options(options)
    contest_options = ContestOptions.new(options)
    contest_params = contest_options.contest
    design_category = DesignCategory.find_by_id(contest_params[:design_category_id])
    @category = DesignCategoryView.new(design_category)
    @design_area = DesignSpace.find_by_id(contest_params[:design_space_id])
    @designer_level = DesignerLevel.find_by_id(contest_options.designer_level)
    @appeal_scales = AppealScale.from(contest_options.appeals)
    @desirable_colors = contest_params[:desirable_colors]
    @undesirable_colors = contest_params[:undesirable_colors]
    @examples = contest_options.liked_example_ids.try(:map) { |example_id| Image.find(example_id).medium_size_url }
    @example_ids = contest_options.liked_example_ids
    @links = contest_options.example_links
    @dimensions = SpaceDimension.from(contest_params)
    @space_pictures = contest_options.space_image_ids.try(:map) { |example_id| Image.find(example_id).medium_size_url }
    @space_pictures_ids = contest_options.space_image_ids
    @space_budget_value = contest_params[:space_budget].to_i
    @budget = CONTEST_DESIGN_BUDGETS[contest_params[:space_budget].to_i]
    @feedback = contest_params[:feedback]
    @budget_plan = contest_params[:budget_plan]
    @name = contest_params[:project_name]
    set_additional_preferences(contest_params)
    set_accommodation(contest_params)
  end

  def initialize_from_contest(contest)
    @category = DesignCategoryView.new(contest.design_category)
    @design_area = contest.design_space
    @designer_level = contest.client.designer_level
    @appeal_scales = AppealScale.from(contest.contests_appeals.includes(:appeal))
    @desirable_colors = contest.desirable_colors
    @undesirable_colors = contest.undesirable_colors
    @examples = contest.liked_examples.map { |example| example.medium_size_url }
    @example_ids = contest.liked_examples.pluck(:id)
    @links = contest.liked_external_examples.pluck(:url)
    @dimensions = SpaceDimension.from(contest)
    @space_pictures = contest.space_images.map { |space_image| space_image.medium_size_url }
    @space_pictures_ids = contest.space_images.pluck(:id)
    @space_budget_value = contest.space_budget.to_i
    @budget = CONTEST_DESIGN_BUDGETS[contest.space_budget.to_i]
    @feedback = contest.feedback
    @budget_plan = contest.budget_plan
    @name = contest.project_name
    @retailers = PreferredRetailers::RETAILERS.map do |retailer|
      { name: retailer, value: contest.preferred_retailers.send(retailer) }
    end
    @other_retailers = contest.preferred_retailers.other
    @elements_to_avoid = contest.elements_to_avoid
    @entertaining = contest.entertaining
    @durability = contest.durability
    set_additional_preferences(contest.attributes.with_indifferent_access)
    set_accommodation(contest.attributes.with_indifferent_access)
  end

  def set_accommodation(options)
    accommodation_attributes = ACCOMMODATION_ATTRIBUTES.map do |accommodation_attribute|
      value = options[accommodation_attribute]
      [accommodation_attribute, value] if value
    end
    @accommodation = Hash[accommodation_attributes.compact]
  end

  def set_additional_preferences(options)
    additional_preferences = ContestAdditionalPreference.preferences.map do |preference|
      value = options[preference]
      [ContestAdditionalPreference.new(preference), value] if value
    end
    @additional_preferences = additional_preferences.compact
  end

  def set_have_space_views_details
    @have_space_views_details = @dimensions.find { |dimension| dimension.value.present? } || @space_pictures_ids.present?
  end

  def set_have_examples
    @have_examples = @links.present? || @example_ids.present?
  end
end
