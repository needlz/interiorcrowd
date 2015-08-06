class InstantFeedbackPublisher

  def initialize(request_id)
    @client = Ably::Rest.new(key: Settings.ably.api_key)
    @channel_name = self.class.channel_name(request_id)
    @channel = @client.channel(@channel_name)
  end

  def publish(changed_mark_params)
    channel.publish(channel_name, changed_mark_params)
  end

  def self.channel_name(request_id)
    Settings.ably.product_item_feedback + request_id.to_s
  end

  private

  attr_reader :channel, :channel_name
end
