require "rails_helper"

RSpec.describe CreditCard do
  let(:client) { Fabricate(:client) }
  let(:card_number) { '4242424242424242' }
  let(:credit_card) do
    Fabricate(:credit_card,
              last_4_digits: card_number.last(4),
              stripe_id: '1')
  end
  let(:duplicate_credit_card) do
    Fabricate(:credit_card,
              last_4_digits: card_number.last(4),
              stripe_id: '1')
  end

  it 'stores field filled with spaces as nil value' do
    credit_card.name_on_card = ' ' * 5
    credit_card.address = ' ' * 5
    credit_card.state = ' ' * 5
    credit_card.city = ' ' * 5
    credit_card.save
    credit_card.reload
    expect(credit_card.name_on_card).to eq(nil)
    expect(credit_card.address).to eq(nil)
    expect(credit_card.state).to eq(nil)
    expect(credit_card.city).to eq(nil)
  end

  it 'must have expiration month and year specified' do
    credit_card.ex_month = nil
    credit_card.ex_year = nil

    expect(credit_card.invalid?).to be_truthy
  end

  it 'must have expiration month and year specified' do
    credit_card.ex_month = nil
    credit_card.ex_year = nil

    expect(credit_card.invalid?).to be_truthy
  end

  it 'must have cvc code specified' do
    credit_card.cvc = nil

    expect(credit_card.invalid?).to be_truthy
  end

  it 'disallows user to have more than one card with the same stripe_id' do
    client.credit_cards << credit_card
    client.credit_cards << duplicate_credit_card
    saved_client = Client.find(client)

    expect(saved_client.credit_cards).to eq([credit_card])
  end

  it 'should have zip containing 5 digits' do
    credit_card.zip = 4444
    expect{credit_card.save!}.to raise_exception(ActiveRecord::RecordInvalid,
                                                 /Validation failed: Zip should be 5 digits/)
  end

  it 'should have numeric zip' do
    credit_card.zip = 'test'
    expect{credit_card.save!}.to raise_exception(ActiveRecord::RecordInvalid,
                                                 /Validation failed: Zip should be 5 digits/)
  end

  it 'should have numeric cvc code' do
    credit_card.cvc = 'test'
    expect{credit_card.save!}.to raise_exception(ActiveRecord::RecordInvalid,
                                                 /Validation failed: Cvc is not a number/)
  end

  context 'when there are more than one credit card' do
    let(:older_credit_card) { Fabricate(:credit_card, created_at: Time.now - 1.day) }
    let(:new_credit_card) { Fabricate(:credit_card) }
    let(:oldest_credit_card) { Fabricate(:credit_card, created_at: Time.now - 1.month) }

    it 'should display cards from the last added ones to older cards' do
      expect(CreditCard.from_newer_to_older).to eq([new_credit_card, older_credit_card, oldest_credit_card])
    end
  end


end
