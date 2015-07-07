module Jobs

  class Payment

    def self.schedule(contest_id, args = {})
      Delayed::Job.enqueue(new(contest_id), args.merge(contest_id: contest_id))
    end

    def initialize(contest_id)
      @contest = Contest.find(contest_id)
    end

    def perform
      payment = ::Payment.new(contest)
      payment.perform
    end

    def queue_name
      Jobs::STRIPE_QUEUE
    end

    private

    attr_reader :contest

  end

end
