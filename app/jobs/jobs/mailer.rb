module Jobs

  MAILER_QUEUE = 'mailer'

  class Mailer

    def self.schedule(mailer_method, mail_args, args = {})
      Delayed::Job.enqueue(new(mailer_method, mail_args), args)
    end

    def initialize(mailer_method, mail_args)
      @mailer_method = mailer_method
      @mail_args = mail_args
    end

    def perform
      UserMailer.new.send(mailer_method, *mail_args)
    end

    def queue_name
      Jobs::MAILER_QUEUE
    end

    private

    attr_reader :mail_args, :mailer_method

  end

end
