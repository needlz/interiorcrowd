module Jobs

  class CheckIfClientLeftIntakeForm

    INACTIVITY_PERIOD = 10.minutes
    MAILER_METHOD = :account_creation

    def self.schedule(client_id, args)
      Delayed::Job.enqueue(new(client_id), args)
    end

    def initialize(client_id)
      @client_id = client_id
    end

    def perform
      client = Client.find(client_id)
      return if client.latest_contest_created_at
      if client.last_activity_at < (Time.current - INACTIVITY_PERIOD)
        Jobs::Mailer.schedule(MAILER_METHOD, [client.id])
      else
        self.class.schedule(client.id, run_at: Time.current + (INACTIVITY_PERIOD / 2))
      end
    end

    def queue_name
      Jobs::CONTESTS_QUEUE
    end

    private

    attr_reader :client_id

  end
end
