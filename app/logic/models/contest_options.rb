class ContestOptions

  attr_reader :appeals, :space_image_ids, :liked_example_ids, :example_links, :contest, :preferred_retailers

  def initialize(hash_or_active_record)
    if hash_or_active_record.kind_of?(Contest)
      initialize_from_contest(hash_or_active_record)
    else
      initialize_from_hash(hash_or_active_record)
    end
  end

  def self.calculate_inches(options, dimension_name)
    dimension = dimension_name.to_sym
    sign_inches = "#{dimension}_inches".to_sym
    feet_in_inches = options[dimension].to_f * 12 if options.try(:[], dimension).present?
    inches = options[sign_inches] if options.try(:[], sign_inches).present?
    feet_in_inches.to_f + inches.to_f if feet_in_inches || inches
  end

  private

  def initialize_from_contest(contest_record)
    @contest = {}
    @contest[:design_category_id] = contest_record.design_category_id
    @contest[:design_space_ids] = contest_record.design_spaces.pluck(:id)
    @contest[:space_length] = contest_record.space_length
    @contest[:space_width] = contest_record.space_width
    @contest[:space_height] = contest_record.space_height
    @contest[:space_budget] = contest_record.space_budget
    @contest[:feedback] = contest_record.feedback
    @contest[:budget_plan] = contest_record.budget_plan
    @contest[:project_name] = contest_record.project_name
    @contest[:desirable_colors] = contest_record.desirable_colors
    @contest[:undesirable_colors] = contest_record.undesirable_colors
    @contest[:elements_to_avoid] = contest_record.elements_to_avoid
    @contest[:entertaining] = contest_record.entertaining
    @contest[:durability] = contest_record.durability
    ContestAdditionalPreference.preferences.each do |preference|
      @contest[preference] = contest_record.send(preference)
    end
    @contest[:designers_explore_other_colors] = contest_record.designers_explore_other_colors
    @contest[:designers_only_use_these_colors] = contest_record.designers_only_use_these_colors
    @contest[:client_id] = contest_record.client.id
    @contest[:accommodate_children] = contest_record.accommodate_children
    @contest[:accommodate_pets] = contest_record.accommodate_pets
    @contest[:location_zip] = contest_record.location_zip

    @space_image_ids = contest_record.space_images.pluck(:id)
    @appeals = contest_record.contests_appeals
    @liked_example_ids = contest_record.liked_examples.pluck(:id)
    @example_links = contest_record.liked_external_examples.pluck(:url)
    @contest[:designer_level_id] = contest_record.designer_level_id

    @preferred_retailers = {}
    PreferredRetailers::RETAILERS.each do |retailer|
      attribute =  retailer.to_sym
      @preferred_retailers[attribute] = contest_record.preferred_retailers.send(retailer)
    end
    @preferred_retailers[:other] = contest_record.preferred_retailers.other
  end

  def initialize_from_hash(hash)
    options = hash.with_indifferent_access
    @contest = {}
    if options[:design_space]
      @contest[:space_length] = ContestOptions.calculate_inches(options[:design_space], :length)
      @contest[:space_width] = ContestOptions.calculate_inches(options[:design_space], :width)
      @contest[:space_height] = ContestOptions.calculate_inches(options[:design_space], :height) if options[:design_space].key?(:height)

      @contest[:space_budget] = options[:design_space][:f_budget] if options[:design_space].key?(:f_budget)
      @contest[:location_zip] = options[:design_space][:zip] if options[:design_space].key?(:zip)
      @contest[:feedback] = options[:design_space][:feedback] if options[:design_space].key?(:feedback)
      @space_image_ids = options[:design_space][:document_id].split(',').map(&:strip).map(&:to_i) if options[:design_space][:document_id]
    end
    if options[:preview]
      @contest[:budget_plan] = options[:preview][:b_plan] if options[:preview].key?(:b_plan)
      @contest[:project_name] = options[:preview][:contest_name] if options[:preview].key?(:contest_name)
    end
    if options[:design_style]
      @contest[:design_space_ids] = options[:design_style][:design_area] if options[:design_style].key?(:design_area)
      @contest[:desirable_colors] = options[:design_style][:desirable_colors] if options[:design_style].key?(:desirable_colors)
      @contest[:undesirable_colors] = options[:design_style][:undesirable_colors] if options[:design_style].key?(:undesirable_colors)
      @appeals = options[:design_style][:appeals].deep_symbolize_keys if options[:design_style].key?(:appeals)
      @liked_example_ids = options[:design_style][:document_id].split(',').map(&:strip).map(&:to_i) if options[:design_style][:document_id]
      @example_links = options[:design_style][:ex_links].delete_if(&:blank?) if options[:design_style][:ex_links]
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

end
