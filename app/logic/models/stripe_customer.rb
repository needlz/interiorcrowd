class StripeCustomer

  DEFAULT_COUNTRY = 'US'

  def initialize(user)
    @user = user
  end

  def self.fill_client_info(client)
    stripe_customer = new(client)
    stripe_customer.register if client.stripe_customer_id.blank?
  end

  def self.create_card_attributes(credit_card_attributes)
    { number: credit_card_attributes[:number],
      exp_month: credit_card_attributes[:ex_month],
      exp_year: credit_card_attributes[:ex_year],
      cvc: credit_card_attributes[:cvc],
      name: credit_card_attributes[:name_on_card],
      address_line1: credit_card_attributes[:address],
      address_city: credit_card_attributes[:city],
      address_state: credit_card_attributes[:state],
      address_zip: credit_card_attributes[:zip],
      address_country: DEFAULT_COUNTRY
    }
  end

  def self.update_card_attributes(card)
    { exp_month: card.ex_month,
      exp_year: card.ex_year,
      name: card.name_on_card,
      address_line1: card.address,
      address_city: card.city,
      address_state: card.state,
      address_zip: card.zip,
      address_country: DEFAULT_COUNTRY
    }
  end

  def register
    customer = Stripe::Customer.create(
      email: user.email,
      description: user.name,
      metadata: { role: user.role, user_id: user.id, name: user.name }
    )
    ActiveRecord::Base.transaction do
      user.update_attributes!(stripe_customer_id: customer.id)
    end
  end

  def stripe_customer
    raise('The user has no Stripe customer id') unless user.stripe_customer_id
    @stripe_customer ||= Stripe::Customer.retrieve(user.stripe_customer_id)
  end

  def import_card(credit_card_attributes)
    StripeCustomer.fill_client_info(user)
    card_options = StripeCustomer.create_card_attributes(credit_card_attributes)
    add_card(card_options)
  end

  def add_card(card_options_or_token)
    card = stripe_customer.sources.create({ source: card_options_or_token.merge(object: 'card') })
    card
  end

  def cards
    stripe_customer.sources.all(limit: 100, object: 'card')
  end

  def default_card
    data = cards.data
    data.last
  end

  def charge(options)
    money = options[:money]
    Stripe::Charge.create(
      amount: money.cents,
      currency: money.currency,
      customer: stripe_customer.id,
      source: options[:card_id],
      description: options[:description]
    )
  end

  def update_card(credit_card)
    card = stripe_customer.sources.retrieve(credit_card.stripe_id)
    fail(user.stripe_card_status) unless card
    attributes = StripeCustomer.update_card_attributes(credit_card)
    attributes.each { |key, value| card.send("#{ key }=", value) }
    card.save
  end

  def delete_card(credit_card)
    stripe_customer.sources.retrieve(credit_card.stripe_id).delete
  end

  def set_default(credit_card)
    stripe_customer.default_card = credit_card.stripe_id
    stripe_customer.save
  end

  private

  attr_reader :user

end
