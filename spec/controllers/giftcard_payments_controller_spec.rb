require 'rails_helper'

RSpec.describe GiftcardPaymentsController, type: :controller do
  render_views

  describe 'GET new' do
    it 'returns page' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:amount) { 20 }
    let(:email) { 'email@example.com' }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:brokerage) { 'Roman&Co' }
    let(:phone) { ['555', '555', '5555'] }
    let(:params) do
      { giftcard_payment:
        { email: email,
          token: 'token',
          quantity: amount.to_s,
          first_name: first_name,
          last_name: last_name,
          brokerage: brokerage,
          phone: phone
        }
      }
    end

    context 'when valid credit card data' do
      let(:charge_id) { 'stripe_change_id' }

      before do
        allow_any_instance_of(BuyGiftcards).to receive(:pay) do
          Hashie::Mash.new(id: charge_id)
        end
      end

      it 'creates payment' do
        expect { post :create, params }.to change { GiftcardPayment.count }.from(0).to(1)
        payment = GiftcardPayment.last
        expect(payment.email).to eq email
        expect(payment.stripe_charge_id).to eq charge_id
        expect(payment.quantity).to eq amount
        expect(payment.first_name).to eq first_name
        expect(payment.last_name).to eq last_name
        expect(payment.brokerage).to eq brokerage
        expect(payment.phone).to eq phone.join
      end
    end

    context 'when invalid credit card data' do
      before do
        allow_any_instance_of(BuyGiftcards).to receive(:pay) do
          raise Stripe::StripeError.new('error!')
        end
      end

      it 'does not create payment' do
        post :create, params
        expect(GiftcardPayment.count).to eq 0
      end
    end
  end

  describe 'GET index' do
    context 'when email provided' do
      let(:email) { 'email@example.com' }
      let!(:giftcards_payment) { Fabricate(:giftcard_payment, email: email) }

      it 'returns page' do
        get :index, email: email
      end
    end
  end

end
