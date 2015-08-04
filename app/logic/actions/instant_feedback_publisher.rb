class InstantFeedbackPublisher
  def initialize
    @client = Ably::Rest.new(key: Settings.ably.api_key)
    @channel = client.channel('product_item_feedback')
  end

  def publish(changed_mark_params)
    channel.publish(changed_mark_params)
  end

  private

  attr_accessor :channel
end