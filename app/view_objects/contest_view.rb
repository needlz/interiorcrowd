class ContestView

  ACCOMMODATION_ATTRIBUTES = [:accommodate_children, :accommodate_pets]

  attr_reader :dimensions, :appeal_scales, :category, :design_areas, :desirable_colors, :undesirable_colors, :examples,
              :links, :space_pictures, :feedback, :budget_plan, :name, :designer_level, :example_ids,
              :space_pictures_ids, :additional_preferences, :have_space_views_details, :have_examples,
              :space_budget_value, :retailers, :other_retailers, :package_view, :package, :allow_download_all_photo,
              :designers_explore_other_colors, :designers_only_use_these_colors, :design_spaces_list

  ContestAdditionalPreference.preferences.map do |preference|
    attr_reader preference
  end

  ACCOMMODATION_ATTRIBUTES.each do |attribute|
    attr_reader attribute
  end

  EDITABLE_ATTRIBUTES = [
    :design_package, :category, :area, :design_profile, :desirable_colors, :undesirable_colors,
    :example_pictures, :budget, :example_links, :space_pictures, :space_dimensions, :feedback,
    :additional_preferences, :preferences_retailers, :element_to_avoid, :entertaining, :durability
  ] + ACCOMMODATION_ATTRIBUTES

  CONTEST_PREVIEW_ATTRIBUTES = [
    :name, :location, :design_knowledge, :category, :area, :design_profile, :desirable_colors, :undesirable_colors,
    :example_pictures, :budget, :example_links, :space_pictures, :space_dimensions, :feedback,
    :additional_preferences, :preferences_retailers, :element_to_avoid, :entertaining, :durability
  ] + ACCOMMODATION_ATTRIBUTES

  LEVELS = {
    2 => :very,
    1 => :somewhat,
    0 => :not
  }

  def initialize(options)
    if options[:contest_attributes].kind_of?(Hash)
      initialize_from_options(HashWithIndifferentAccess.new(options[:contest_attributes]))
    else
      initialize_from_contest(options[:contest_attributes])
    end
    @allow_download_all_photo = options[:allow_download_all_photo]
    set_have_space_views_details
    set_have_examples
  end

  def top_level_area_active?(area)
    design_areas.include?(area) || design_areas.map(&:parent).include?(area)
  end


  def conditional_block_radio_button_active?(is_block_visible, button_value)
    active_button_value = is_block_visible ? 'yes' : 'no'
    button_value == active_button_value
  end

  def package_selected?(package_id)
    package_id == @budget_plan.to_i
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
    return '' unless level
    '(' + I18n.t("client_center.entries.option_levels.#{ LEVELS[level.to_i] }") + ')'
  end

  def entertaining
    options_level(@entertaining)
  end

  def durability
    options_level(@durability)
  end

  def download_all_photo_button_visible?
    allow_download_all_photo && space_pictures.present?
  end

  def order_total
    total = @package.try(:price) || BudgetPlan.all.last.price
    '$ ' + total.to_s + '.00'
  end

  private

  def initialize_from_options(options)
    contest_options = ContestOptions.new(options)
    contest_params = contest_options.contest
    design_category = DesignCategory.find_by_id(contest_params[:design_category_id])
    @category = DesignCategoryView.new(design_category)
    @design_areas = DesignSpace.where(id: contest_params[:design_space_ids])
    @designer_level = DesignerLevel.find_by_id(contest_options.designer_level)
    @appeal_scales = AppealScale.from(contest_options.appeals)
    @desirable_colors = contest_params[:desirable_colors]
    @undesirable_colors = contest_params[:undesirable_colors]
    @example_ids = contest_options.liked_example_ids
    @examples = Image.where(id: contest_options.liked_example_ids).order(:created_at)
    @links = contest_options.example_links
    @dimensions = SpaceDimension.from(contest_params)
    @space_pictures_ids = contest_options.space_image_ids
    @space_pictures = Image.where(id: contest_options.space_image_ids).order(:created_at)
    @space_budget_value = contest_params[:space_budget]
    @feedback = contest_params[:feedback]
    @name = contest_params[:project_name]
    @designers_explore_other_colors = contest_params[:designers_explore_other_colors]
    @designers_only_use_these_colors = contest_params[:designers_only_use_these_colors]
    @design_spaces_list = @design_areas.map(&:full_name).join(', ')
    set_package(contest_params)
    set_additional_preferences(contest_params)
    set_accommodation(contest_params)
  end

  def initialize_from_contest(contest)
    @category = DesignCategoryView.new(contest.design_category)
    @design_areas = contest.design_spaces
    @designer_level = contest.client.designer_level
    @appeal_scales = AppealScale.from(contest.contests_appeals.includes(:appeal))
    @desirable_colors = contest.desirable_colors
    @undesirable_colors = contest.undesirable_colors
    @example_ids = contest.liked_examples.pluck(:id)
    @examples = contest.liked_examples.order(:created_at)
    @links = contest.liked_external_examples.pluck(:url)
    @dimensions = SpaceDimension.from(contest)
    @space_pictures_ids = contest.space_images.pluck(:id)
    @space_pictures = contest.space_images.order(:created_at)
    @space_budget_value = contest.space_budget
    @feedback = contest.feedback
    @name = contest.project_name
    @retailers = PreferredRetailers::RETAILERS.map do |retailer|
      { name: retailer, value: contest.preferred_retailers.send(retailer) }
    end
    @other_retailers = contest.preferred_retailers.other
    @elements_to_avoid = contest.elements_to_avoid
    @entertaining = contest.entertaining
    @durability = contest.durability
    @designers_explore_other_colors = contest.designers_explore_other_colors
    @designers_only_use_these_colors = contest.designers_only_use_these_colors
    @design_spaces_list = @design_areas.map(&:full_name).join(', ')
    set_package(contest.attributes.with_indifferent_access)
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
    @additional_preferences = additional_preferences.compact.map do |preference, value|
      I18n.t("contests.additional_details.#{ preference.name }.#{ value }")
    end.join(', ')
    @additional_preferences = "(#{ @additional_preferences })" if @additional_preferences.present?
  end

  def set_have_space_views_details
    @have_space_views_details = @space_pictures_ids.present?
  end

  def set_have_examples
    @have_examples = @example_ids.present?
  end

  def set_package(contest_params)
    @budget_plan = contest_params[:budget_plan]
    @package = BudgetPlan.find(budget_plan) if budget_plan
    @package_view = PackageView.new(BudgetPlan.find(budget_plan)) if package
  end
end
