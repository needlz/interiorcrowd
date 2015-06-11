class ClientInitialization

  def initialize(options)
    @client = options[:client]
    @plain_password = options[:plain_password]
    @promocode_token = options[:promocode]
  end

  def perform
    promocode = Promocode.unused.find_by_token(promocode_token)
    client.promocodes << promocode if promocode
    Jobs::Mailer.schedule(:client_registered, [client])
    Jobs::Mailer.schedule(:user_registration_info, [client])
  end

  private

  attr_reader :client, :plain_password, :promocode_token

end
