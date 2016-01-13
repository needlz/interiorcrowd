class EmailWebhooksController < ApplicationController
  include Mandrill::Rails::WebHookProcessor

  unhandled_events_raise_exceptions!

  OUTBOUND_MANDRILL_EVENTS = %w[send deferral hard_bounce soft_bounce reject]

  OUTBOUND_MANDRILL_EVENTS.each do |event|
    define_method "handle_#{ event }" do |event_payload|
      process_event(event_payload)
    end
  end

  def create_with_saving
    @request_json = params['mandrill_events']
    create_without_saving
  end

  alias_method :create_without_saving, :create
  alias_method :create, :create_with_saving

  def handle_inbound(event_payload)
    inbound_processor = MandrillInboundEmailProcessor.new(@request_json, event_payload)
    inbound_processor.process
  end

  def verify
    head :ok
  end

  private

  def process_event(event_payload)
    email = OutboundEmail.find_by_id(event_payload['msg']['metadata']['email_id'])
    email.update_attributes!(status: event_payload['event'], sent_to_mail_server_at: Time.at(event_payload['ts'])) if email
  end

end
