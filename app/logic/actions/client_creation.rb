class ClientCreation

  attr_reader :saved, :client

  def initialize(options)
    @client_attributes = options[:client_attributes]
    @saved = false
  end

  def perform
    return unless create_client
    send_notifications
    self
  end

  private

  attr_reader :client_attributes

  def create_client
    @client = Client.new(client_attributes)
    @saved = @client.save
  end

  def send_notifications
    Jobs::Mailer.schedule(:client_registered, [client])
    Jobs::Mailer.schedule(:user_registration_info, [client])
  end

end
