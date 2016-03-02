module ContestValidation

  class Base

    def initialize(contest_options)
      @contest_options = contest_options
    end

    def uncompleted_step(validated_steps = Base.required_options_by_step.keys)
      steps_with_validated_attributes = self.class.required_options_by_step.slice(*validated_steps)
      steps_with_validated_attributes.each do |step, attributes|
        return step if (missing_options & attributes).present?
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
