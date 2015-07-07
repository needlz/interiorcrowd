class ClientInitialization

  def initialize(options)
    @client = options[:client]
    @plain_password = options[:plain_password]
  end

  def perform

    Jobs::Mailer.schedule(:client_registered, [client])
    Jobs::Mailer.schedule(:user_registration_info, [client])
  end

  private

  attr_reader :client, :plain_password

end
