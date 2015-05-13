class ClientUpdater

  def initialize(options)
    @client = options[:client]
    @client_attributes = options[:client_attributes]
    @password_options = options[:password_options]
  end

  def perform
    client.update_attributes!(client_attributes) if client_attributes
    update_password if password_options
  end

  private

  attr_reader :client, :client_attributes, :password_options

  def update_password
    if verify_password && new_password_valid?
      client.set_password(password_options[:new_password])
      client.save!
    end
  end

  def new_password_valid?
    password_options[:new_password].present? && (password_options[:new_password] == password_options[:confirm_password])
  end

  def verify_password
    client.valid_password?(password_options[:old_password])
  end

end
