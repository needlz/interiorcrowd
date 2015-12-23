require 'rails_helper'

RSpec.describe GiftcardPayment, type: :model do

  describe 'validation' do
    let(:giftcard_payment) { Fabricate(:giftcard_payment) }

    context 'when valid email' do
      let(:email) { 'email@example.com' }

      it 'saves changes' do
        expect { giftcard_payment.update_attributes!(email: email) }.to_not raise_error
      end
    end

    context 'when invalid email' do
      let(:email) { 'email@example' }

      it 'does not save changes' do
        expect { giftcard_payment.update_attributes!(email: email) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

  end

end
