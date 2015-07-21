class ClientUpdater

  def initialize(options)
    @client = options[:client]
    @client_attributes = options[:client_attributes]
    @password_options = options[:password_options]
  end

  def perform
    if client_attributes
      do_register = false
      client.assign_attributes(client_attributes)
      if billing_info_changed?(client)
        if client.stripe_customer?
          stripe_customer = StripeCustomer.new(client)
          if client.card_number_changed?
            stripe_customer.try_add_default_card
          else
            stripe_customer.update_default_card
          end
        else
          do_register = true
        end
      end
      client.save!
      if do_register
        Jobs::StripeCustomerRegistration.schedule(client)
      end
    end
    update_password if password_options
  end

  private

  attr_reader :client, :client_attributes, :password_options

  def stripe_card_attributes

  end

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

  def billing_info_changed?(client)
    [:card_number, :card_ex_month, :card_ex_year, :card_cvc, :name_on_card,
     :address, :city, :state, :zip]
  end

end
