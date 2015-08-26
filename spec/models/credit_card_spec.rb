require "rails_helper"

RSpec.describe CreditCard do
  let(:client) { Fabricate(:client) }
  let(:credit_card) { Fabricate(:credit_card) }
  let(:duplicate_credit_card) { Fabricate(:credit_card, number: credit_card.number) }

  it 'should have zip containing 5 digits' do
    credit_card.zip = 4444
    expect{credit_card.save!}.to raise_exception(ActiveRecord::RecordInvalid,
                                                 /Validation failed: Zip should be 5 digits/)
  end

  it 'disallows user to have more than one card with the same number' do
    client.credit_cards << credit_card
    client.credit_cards << duplicate_credit_card
    saved_client = Client.find(client)

    expect(saved_client.credit_cards).to eq([credit_card])
  end

end
