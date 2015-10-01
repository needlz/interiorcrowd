require 'rails_helper'

RSpec.describe ClientPayment do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

  before do
    allow_any_instance_of(StripeCustomer).to receive(:charge){}
  end

  describe 'uniqueness validation' do
    it 'does not allow to create more than one payment for a contest' do
      ClientPayment.create!(payment_status: 'pending', client_id: client.id, contest_id: contest.id)
      expect do
        ClientPayment.create!(payment_status: 'pending', client_id: client.id, contest_id: contest.id)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

end
