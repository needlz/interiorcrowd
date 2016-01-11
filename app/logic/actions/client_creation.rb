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
      send_notifications
      self
    end
  end

  private

  attr_reader :client_attributes

  def create_client
    @client = Client.new(client_attributes)
    @saved = @client.save
  end

  def send_notifications
    email = @send_welcome_email ? :account_creation : :client_registered
    Jobs::Mailer.schedule(email, [client.id])
  end

end
