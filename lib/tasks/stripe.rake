namespace :stripe do
  desc 'register Stripe customers for existing users'
  task register: :environment do
    Client.where(id: 35).each do |client|
      begin
        StripeCustomer.fill_client_info(client)
      rescue Stripe::StripeError => e
        p e
      end
    end
  end
end
