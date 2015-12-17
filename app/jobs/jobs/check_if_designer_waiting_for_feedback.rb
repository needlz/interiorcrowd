module Jobs

  class CheckIfDesignerWaitingForFeedback

    def self.schedule(contest_id, args)
      Delayed::Job.enqueue(new(contest_id), { contest_id: contest_id }.merge(args))
    end

    def initialize(contest_id)
      @contest = Contest.find(contest_id)
    end

    def perform
      if contest.submission? && contest.submitted_contests.count < 1
        Jobs::Mailer.schedule(:no_concept_boards_received_after_three_days, [contest])
      end
    end

    def queue_name
      Jobs::CONTESTS_QUEUE
    end

    private

    attr_reader :contest

  end
end
