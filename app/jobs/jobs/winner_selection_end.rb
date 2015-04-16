module Jobs

  class WinnerSelectionEnd

    def self.schedule(contest_id, args)
      Delayed::Job.enqueue(new(contest_id), { contest_id: contest_id }.merge(args))
    end

    def initialize(contest_id)
      @contest_id = contest_id
    end

    def perform
      contest = Contest.find(contest_id)
      contest.close!
    end

    def queue_name
      Jobs::CONTESTS_QUEUE
    end

    private

    attr_reader :contest_id

  end
end
