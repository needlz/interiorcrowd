class ClientCheckout

  class CheckoutError < StandardError; end

  def initialize(options)
    @contest = options[:contest]
    @promocode = options[:promocode]
    @agreed_with_terms_of_use = options[:agreed_with_terms_of_use]
    @client = options[:client]
    @new_credit_card_attributes = options[:new_credit_card_attributes]
  end

  def perform
    raise CheckoutError.new('To proceed, you need to agree to the Terms of use') unless agreed_with_terms_of_use
    ActiveRecord::Base.transaction do
      apply_promocode
      do_payment
    end
  end

  private

  attr_reader :contest, :agreed_with_terms_of_use, :promocode, :client, :new_credit_card_attributes

  def apply_promocode
    ApplyPromocode.new(contest, promocode).perform
  end

  def do_payment
    prepare_card
    try_checkout_with_existing_card
    log_client_actions
    NotifyAboutClientSignUpComplete.new(client).perform
    SubmitContest.new(contest).try_perform
  end

  def log_client_actions
    client_contest_created_at = {latest_contest_created_at: Time.current}
    client_contest_created_at.merge!(first_contest_created_at: Time.current) if client.contests.count == 1
    client.update_attributes!(client_contest_created_at)
  end

  def try_checkout_with_existing_card
    if Settings.automatic_checkout_enabled
      payment = CreateClientPayment.new(contest)
      payment.perform
    end
  end

  def prepare_card
    if new_credit_card_attributes.present?
      raise CheckoutError.new('The client already has credit cards') if client.credit_cards.present?
      add_card = AddCreditCard.new(client: client, card_attributes: new_credit_card_attributes, set_as_primary: true)
      add_card.perform
    end
  end

end
