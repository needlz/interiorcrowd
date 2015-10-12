class OutboundEmailsController < ApplicationController
  include Mandrill::Rails::WebHookProcessor
  unhandled_events_raise_exceptions!

  MANDRILL_EVENTS = %w[send deferral hard_bounce soft_bounce reject]

  MANDRILL_EVENTS.each do |event|
    define_method "handle_#{ event }" do |event_payload|
      process_event(event_payload)
    end
  end

  private

  def process_event(event_payload)
    email = OutboundEmail.find_by_id(event_payload['msg']['metadata']['email_id'])
    email.update_attributes!(status: event_payload['event'], sent_to_mail_server_at: Time.at(event_payload['ts'])) if email
  end

end
