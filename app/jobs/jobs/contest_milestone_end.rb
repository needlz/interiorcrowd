module Jobs

  class ContestMilestoneEnd

    def self.schedule(contest_id, contest_status, args)
      Delayed::Job.enqueue(new(contest_id, contest_status), { contest_id: contest_id }.merge(args))
    end

    def initialize(contest_id, contest_status)
      @contest_id = contest_id
      @contest_status = contest_status
    end

    def perform
      contest = Contest.find(contest_id)
      end_milestone_class = ContestMilestone.end_milestone_performer(contest_status)
      end_milestone = end_milestone_class.new(contest)
      end_milestone.perform
    end

    def queue_name
      Jobs::CONTESTS_QUEUE
    end

    private

    attr_reader :contest_id, :contest_status

  end
end
