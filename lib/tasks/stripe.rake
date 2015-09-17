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

  desc 'restore cards'
  task restore_cards: :environment do
    contests = Contest.all.select do |c|
      c.client_payment.present? && c.client.credit_cards.blank?
    end
    clients =contests.map(&:client)
    clients.map do |cl|
      sc=StripeCustomer.new(cl);
      dc=sc.default_card;
      card = CreditCard.create!(stripe_id: dc[:id],
                         client_id: cl.id,
                         name_on_card: dc[:name],
                         card_type: dc[:brand],
                         address: dc[:address_line1],
                         state: dc[:address_state],
                         zip: dc[:address_zip],
                         city: dc[:address_city],
                         ex_month: dc[:exp_month],
                         ex_year: dc[:exp_year],
                         last_4_digits: dc[:last4])
      cl.update_attributes!(primary_card_id: card.id)
    end

  end
end
