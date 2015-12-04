require 'rails_helper'

RSpec.describe AddCreditCard do
  let(:client) { Fabricate(:client) }

  before do
    mock_stripe_card_adding
    mock_stripe_setting_default_card
  end

end
