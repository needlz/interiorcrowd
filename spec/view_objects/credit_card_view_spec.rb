require "rails_helper"

RSpec.describe CreditCardView do
  let(:credit_card) { Fabricate(:credit_card) }
  let(:client) { Fabricate(:client, primary_card: credit_card) }

  before do
    @card_view = CreditCardView.new(credit_card)
  end

  it 'return correct param' do
    expect(@card_view.params[I18n.t('client_center.sign_up.credit_card.name')]).to eq(credit_card.name_on_card)
  end

  it 'returns correct parameters for select HTML element' do

    expect(@card_view.year_select[:start_year]).to eq(Time.now.year)
  end

  it 'returns correct CSS class for primary card' do
    credit_card.client = client
    expect(@card_view.css_class).to eq('primary-card-params')
  end
end
