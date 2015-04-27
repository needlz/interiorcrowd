module Jobs

  class MixpanelLogRecord

    def self.schedule(type, message, args = {})
      Delayed::Job.enqueue(new(type, message), args)
    end

    def initialize(type, message)
      @type = type
      @message = message
    end

    def perform
      mixpanel = Mixpanel::Consumer.new
      mixpanel.send!(type, message)
    end

    def queue_name
      Jobs::MIXPANEL_QUEUE
    end

    private

    attr_reader :type, :message

  end

end
