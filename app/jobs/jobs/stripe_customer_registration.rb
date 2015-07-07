module Jobs

  class StripeCustomerRegistration

    def self.schedule(client, args = {})
      Delayed::Job.enqueue(new(client), args)
    end

    def initialize(client)
      @client = client
    end

    def perform
      StripeCustomer.fill_client_info(client)
    end

    def queue_name
      Jobs::STRIPE_QUEUE
    end

    private

    attr_reader :client

  end

end
