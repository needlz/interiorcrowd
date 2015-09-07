class StripeCustomer

  DEFAULT_COUNTRY = 'US'

  def initialize(user)
    @user = user
  end

  def self.fill_client_info(client)
    stripe_customer = new(client)
    stripe_customer.register if client.stripe_customer_id.blank?
  end

  def self.card_attributes(card)
    { number: card.number,
      exp_month: card.ex_month,
      exp_year: card.ex_year,
      cvc: card.cvc,
      name: card.name_on_card,
      address_line1: card.address,
      address_city: card.city,
      address_state: card.state,
      address_zip: card.zip,
      address_country: DEFAULT_COUNTRY
    }
  end

  def self.card_token_from_client(client)
    Stripe::Token.create({ card: card_attributes(client) }).id
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

  def import_card(credit_card)
    StripeCustomer.fill_client_info(user)
    card_options = StripeCustomer.card_attributes(credit_card)
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

  def update_default_card
    attributes =
      { exp_month: user.card_ex_month,
        exp_year: user.card_ex_year,
        name: user.name_on_card,
        address_line1: user.billing_address,
        address_city: user.billing_city,
        address_state: user.billing_state,
        address_zip: user.billing_zip,
        address_country: DEFAULT_COUNTRY
      }
    card = default_card
    fail(user.stripe_card_status) unless card
    attributes.each { |key, value| card.send("#{ key }=", value) }
    card.save
  end

  private

  attr_reader :user

end
