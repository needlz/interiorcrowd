module ContestValidation

  class Submission < Creation

    def self.required_options_by_chapter
      super.deep_merge(design_space: [:space_image_ids])
    end

    def missing_options
      attributes = super
      attributes << :space_image_ids if contest_options.space_image_ids.blank?
      attributes
    end

  end

end
