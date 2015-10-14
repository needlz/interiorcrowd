module Jobs

  class Mailer

    def self.schedule(mailer_method, mail_args, args = {})
      email = OutboundEmail.create!(mailer_method: mailer_method, mail_args: mail_args.to_s)
      Delayed::Job.enqueue(new(mailer_method, mail_args, email.id), args)
    end

    def initialize(mailer_method, mail_args, outbound_email_id = nil)
      @mailer_method = mailer_method
      @mail_args = mail_args
      @outbound_email_id = outbound_email_id
    end

    def perform
      UserMailer.send(mailer_method, *mail_args, outbound_email_id).deliver_now
    end

    def queue_name
      Jobs::MAILER_QUEUE
    end

    private

    attr_reader :mail_args, :mailer_method, :outbound_email_id

  end

end
