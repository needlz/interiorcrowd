require 'rails_helper'

RSpec.describe StripeCustomer do

  let(:valid_card_number) { '4242424242424242' }
  let(:card_number_to_decline) { '4000000000000002' }
  let(:card_number_incorrect) { '4242424242424241' }

  def card(params)
    {
      card:
        { number: '',
          exp_month: '',
          exp_year: '',
          cvc: '',
          name: '',
          address_line1: '',
          address_city: '',
          address_state: '',
          address_zip: '',
          address_country: ''
        }.merge(params)
    }
  end

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'brief_pending') }

  describe 'register client' do
    before do
      mock_stripe_customer_registration
    end

    it 'registers customer' do
      StripeCustomer.fill_client_info(client)
      expect(client.stripe_customer_id).to be_present
    end
  end

end
