module ContestRequestMilestones

  class Base

    def initialize(options)
      @contest = options[:contest]
      @contest_request = options[:contest_request]
      @view_context = options[:view_context]
    end

    def expired?
      !in_progress?
    end

    private

    attr_reader :contest, :contest_request, :view_context

    def in_progress?
      Time.current < contest.phase_end
    end

  end

end
