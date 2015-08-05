class InstantFeedbackPublisher
  def initialize
    @client = Ably::Rest.new(key: Settings.ably.api_key)
    @channel_name = 'product_item_feedback'
    @channel = @client.channel(@channel_name)
  end

  def publish(changed_mark_params)
    channel.publish(@channel_name, changed_mark_params)
  end

  private

  attr_reader :channel, :channel_name
end
