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
      view_context.distance_of_time_in_words(Time.current,
                                             contest.phase_end,
                                             vague: true)
    end

    private

    attr_reader :contest, :contest_request, :view_context

    def in_progress?
      Time.current < contest.phase_end
    end

  end

end
