module ContestValidation

  class Creation < Base

    def self.required_contest_attributes
      [:design_category_id, :design_space_ids, :space_budget,
       :budget_plan, :project_name, :desirable_colors, :designer_level_id]
    end

    def self.required_options_by_step
      {
          design_brief: [:design_category_id, :design_space_ids],
          design_style: [:designer_level_id, :appeals, :desirable_colors],
          design_space: [:space_budget],
          preview: [:budget_plan, :project_name]
      }
    end

    def missing_options
      return @missing_options if @missing_options
      @missing_options = super
      @missing_options << :appeals if contest_options.appeals.blank?
      @missing_options
    end

    def step_valid?(step)
      missing_step_attributes = missing_options & self.class.required_options_by_step[step]
      missing_step_attributes.blank?
    end

    private

    attr_reader :contest_options

  end

end
