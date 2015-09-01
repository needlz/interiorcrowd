namespace :stripe do
  desc 'register Stripe customers for existing users'
  task register: :environment do
    Client.each do |client|
      begin
        StripeCustomer.fill_client_info(client)
      rescue Stripe::StripeError => e
        p e
      end
    end
  end

  desc 'register Stripe customers for existing users'
  task register_cards: :environment do
    CreditCard.all.each do |card|
      begin
        client = card.client
        card_id = StripeCustomer.new(client).add_card(StripeCustomer.card_token_from_client(client)).id
        card.update_attributes!(stripe_id: card_id, zip: '%5.5s' % card.zip)
      rescue Stripe::StripeError => e
        p e
      end
    end
  end
end
