class ClientCreation

  attr_reader :saved, :client

  def initialize(options)
    @client_attributes = options[:client_attributes]
    @send_welcome_email = options[:send_welcome_email]
    @saved = false
  end

  def perform
    ActiveRecord::Base.transaction do
      return unless create_client
      client.update_attributes!(last_activity_at: Time.now)
      start_welcoming_timer
      self
    end
  end

  private

  attr_reader :client_attributes

  def create_client
    @client = Client.new(client_attributes)
    @saved = @client.save
  end

  def start_welcoming_timer
    Jobs::CheckIfClientLeftIntakeForm.schedule(
        client.id,
        run_at: Time.current + Jobs::CheckIfClientLeftIntakeForm::INACTIVITY_PERIOD
    )
  end

end
