class ContestOptions

  attr_reader :appeals, :space_image_ids, :liked_example_ids, :example_links, :designer_level, :contest

  REQUIRED_OPTIONS = [:design_category_id, :design_space_id, :space_budget,
                      :budget_plan, :project_name, :desirable_colors]

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
      @contest[:space_height] = ContestOptions.calculate_inches(options[:design_space], :height)

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
    end
    @contest[:client_id] = options[:client_id] if options.has_key?(:client_id)
    if options[:contest]
      @contest[:accommodate_children] = options[:contest][:accommodate_children] if options[:contest].has_key?(:accommodate_children)
      @contest[:accommodate_pets] = options[:contest][:accommodate_pets] if options[:contest].has_key?(:accommodate_pets)
      ContestAdditionalPreference.preferences.each do |preference|
        @contest[preference] = options[:contest][preference] if options[:contest].has_key?(preference)
      end
    end
  end

  def required_present?
    required_contest_options_present = !REQUIRED_OPTIONS.detect { |option| contest[option].blank? }
    required_contest_options_present && appeals.present? && designer_level.present?
  end

  def self.calculate_inches(options, param)
    sign = param.to_sym
    sign_inches = "#{sign}_inches".to_sym
    feet_in_inches = options[sign].to_f * 12 if options.try(:[], sign).present?
    inches = options[sign_inches] if options.try(:[], sign_inches).present?
    feet_in_inches.to_f + inches.to_f if feet_in_inches || inches
  end

end
