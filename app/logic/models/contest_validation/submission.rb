module ContestValidation

  class Submission < Creation

    def self.required_options_by_step
      required_options = super
      required_options[:design_space] << :space_image_ids
      required_options
    end

    def missing_options
      attributes = super
      attributes << :space_image_ids if contest_options.space_image_ids.blank?
      attributes
    end

  end

end
