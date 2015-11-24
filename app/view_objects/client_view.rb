class ClientView

  def initialize(client)
    @client = client
  end

  def city_address
    [client.city, client.state].select(&:present?).join(', ')
  end

  private

  attr_reader :client

end
