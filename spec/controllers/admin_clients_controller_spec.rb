require 'rails_helper'

RSpec.describe Admin::ClientsController, type: :controller do
  include Devise::TestHelpers

  let(:original_password) { Client.encrypt('password') }
  let(:credit_card) { Fabricate(:credit_card) }
  let(:client) { Fabricate(:client, password: original_password, credit_cards: [credit_card]) }

  describe 'PATCH update' do
    before do
      sign_in Fabricate(:admin_user)
    end

    context 'new password empty' do
      let(:new_password_hash) { '  ' }

      it 'does not change password' do
        put :update, id: client.id, client: client.attributes.merge(password: new_password_hash)
        expect(client.reload.password).to eq original_password
      end
    end

    context 'new password not empty' do
      let(:new_password_hash) { 'new_password_hash' }

      it 'changes password' do
        put :update, id: client.id, client: client.attributes.merge(password: new_password_hash)
        expect(client.reload.password).to eq new_password_hash
      end
    end
  end

end
