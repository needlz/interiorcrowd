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

    protected

    def time_left
      DurationHumanizer.to_string(view_context, Time.current, contest.phase_end)
    end

    private

    attr_reader :contest, :contest_request, :view_context

    def in_progress?
      contest.phase_end? && Time.current < contest.phase_end
    end

    def expired_request_during_winner_selection?
      contest.winner_selection? && contest_request.draft?
    end

  end

end
