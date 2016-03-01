module ContestValidation

  class Base

    def initialize(contest_options)
      @contest_options = contest_options
    end

    def uncompleted_step
      self.class.required_options_by_step.each do |chapter, options|
        return chapter if (missing_options & options).present?
      end
      nil
    end

    def missing_options
      self.class.required_contest_attributes.select do |option|
        contest_options.contest[option].blank?
      end
    end

    private

    attr_reader :contest_options

  end

end
