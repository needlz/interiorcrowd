class ContestOptions

  attr_reader :appeals, :space_image_ids, :liked_example_ids, :example_links, :designer_level, :contest, :preferred_retailers

  REQUIRED_CONTEST_ATTRIBUTES = [:design_category_id, :design_space_id, :space_budget,
                      :budget_plan, :project_name, :desirable_colors]

  REQUIRED_OPTIONS_BY_CHAPTER = {
      design_brief: [:design_category_id, :design_space_id],
      design_style: [:designer_level, :appeals, :desirable_colors],
      design_space: [:space_budget],
      preview: [:budget_plan, :project_name]
  }

  def initialize(hash)
    options = hash.with_indifferent_access
    @contest = {}
    if options[:design_brief]
      @contest[:design_category_id] = options[:design_brief][:design_category].to_i if options[:design_brief].key?(:design_category)
      @contest[:design_space_id] = options[:design_brief][:design_area].to_i if options[:design_brief].key?(:design_area)
    end
    if options[:design_space]
      @contest[:space_length] = ContestOptions.calculate_inches(options[:design_space], :length)
      @contest[:space_width] = ContestOptions.calculate_inches(options[:design_space], :width)
      @contest[:space_height] = ContestOptions.calculate_inches(options[:design_space], :height) if options[:design_space].key?(:height)

      @contest[:space_budget] = options[:design_space][:f_budget] if options[:design_space].key?(:f_budget)
      @contest[:feedback] = options[:design_space][:feedback] if options[:design_space].key?(:feedback)
      @space_image_ids = options[:design_space][:document_id].split(',').map(&:strip).map(&:to_i) if options[:design_space][:document_id]
    end
    if options[:preview]
      @contest[:budget_plan] = options[:preview][:b_plan] if options[:preview].key?(:b_plan)
      @contest[:project_name] = options[:preview][:contest_name] if options[:preview].key?(:contest_name)
    end
    if options[:design_style]
      @contest[:desirable_colors] = options[:design_style][:desirable_colors] if options[:design_style].key?(:desirable_colors)
      @contest[:undesirable_colors] = options[:design_style][:undesirable_colors] if options[:design_style].key?(:undesirable_colors)
      @appeals = options[:design_style][:appeals].deep_symbolize_keys if options[:design_style].key?(:appeals)
      @liked_example_ids = options[:design_style][:document_id].split(',').map(&:strip).map(&:to_i) if options[:design_style][:document_id]
      @example_links = options[:design_style][:ex_links].delete_if(&:blank?) if options[:design_style][:ex_links]
      @designer_level = options[:design_style][:designer_level].to_i if options[:design_style].has_key?(:designer_level)
      @contest[:designers_explore_other_colors] = options[:design_style][:designers_explore_other_colors].to_bool if options[:design_style].key?(:designers_explore_other_colors)
      @contest[:designers_only_use_these_colors] = options[:design_style][:designers_only_use_these_colors].to_bool if options[:design_style].key?(:designers_only_use_these_colors)
    end
    @contest[:client_id] = options[:client_id] if options.has_key?(:client_id)
    if options[:contest]
      @contest[:accommodate_children] = options[:contest][:accommodate_children] if options[:contest].has_key?(:accommodate_children)
      @contest[:accommodate_pets] = options[:contest][:accommodate_pets] if options[:contest].has_key?(:accommodate_pets)

      @preferred_retailers = {}
      if options[:contest][:preferred_retailers]
        PreferredRetailers::RETAILERS.each do |retailer|
          attribute =  retailer.to_sym
          @preferred_retailers[attribute] = options[:contest][:preferred_retailers][attribute] if options[:contest][:preferred_retailers].has_key?(attribute)
        end
        @preferred_retailers[:other] = options[:contest][:preferred_retailers][:other] if options[:contest][:preferred_retailers].has_key?(:other)
      end

      @contest[:elements_to_avoid] = options[:contest][:elements_to_avoid] if options[:contest].has_key?(:elements_to_avoid)
      @contest[:entertaining] = options[:contest][:entertaining] if options[:contest].has_key?(:entertaining)
      @contest[:durability] = options[:contest][:durability] if options[:contest].has_key?(:durability)

      ContestAdditionalPreference.preferences.each do |preference|
        @contest[preference] = options[:contest][preference] if options[:contest].has_key?(preference)
      end
    end
  end

  def required_present?
    missing_options.empty?
  end

  def uncompleted_chapter
    missing = missing_options
    REQUIRED_OPTIONS_BY_CHAPTER.each do |chapter, options|
      return chapter if (missing & options).present?
    end
    nil
  end

  private

  def missing_options
    missing_options = REQUIRED_CONTEST_ATTRIBUTES.select { |option| contest[option].blank? }
    missing_options << :appeals if appeals.blank?
    missing_options << :designer_level if designer_level.blank?
    missing_options
  end

  def self.calculate_inches(options, param)
    sign = param.to_sym
    sign_inches = "#{sign}_inches".to_sym
    feet_in_inches = options[sign].to_f * 12 if options.try(:[], sign).present?
    inches = options[sign_inches] if options.try(:[], sign_inches).present?
    feet_in_inches.to_f + inches.to_f if feet_in_inches || inches
  end

end