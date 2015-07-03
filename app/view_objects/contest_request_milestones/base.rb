module ContestRequestMilestones

  class Base

    def initialize(options)
      @contest = options[:contest]
      @contest_request = options[:contest_request]
      @view_context = options[:view_context]
    end

    private

    attr_reader :contest, :contest_request, :view_context

    def expired?
      Time.current < contest.phase_end
    end

  end

end
