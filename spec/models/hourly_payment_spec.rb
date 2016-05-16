require 'rails_helper'

RSpec.describe HourlyPayment, type: :model do
  let(:time_tracker) { Fabricate(:time_tracker) }
  let(:client) { Fabricate(:client) }
  let(:credit_card) { Fabricate(:credit_card) }
  let!(:hourly_payment) { Fabricate(:hourly_payment,
                                   time_tracker: time_tracker,
                                   client: client,
                                   credit_card: credit_card) }


  it 'belongs to time_tracker' do
    expect(hourly_payment.time_tracker).to eq(time_tracker)
  end

  it 'belongs to client' do
    expect(hourly_payment.client).to eq(client)
  end

  it 'belongs to credit card' do
    expect(hourly_payment.credit_card).to eq(credit_card)
  end

  it 'normalizes last error field content' do
    hourly_payment.last_error = '     this text should be normalized     '
    hourly_payment.save
    expect(hourly_payment.last_error).to eq('this text should be normalized')
  end

  it 'sets empty last error to nil' do
    hourly_payment.last_error = ' '
    hourly_payment.save
    expect(hourly_payment.last_error).to be_nil
  end
end
