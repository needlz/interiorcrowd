require 'rails_helper'

RSpec.describe Admin::DesignersController, type: :controller do
  include Devise::TestHelpers

  let(:original_password) { 'password' }
  let(:encrypted_original_password) { Designer.encrypt(original_password) }
  let(:credit_card) { Fabricate(:credit_card) }
  let(:designer) { Fabricate(:designer, password: original_password) }

  describe 'PATCH update' do
    before do
      sign_in Fabricate(:admin_user)
    end

    context 'when changing encrypted password' do
      context 'when encrypted password is empty' do
        let(:encrypted_new_password) { '  ' }

        it 'does not change encrypted password' do
          put :update, id: designer.id, designer: designer.attributes.merge(password: encrypted_new_password)
          expect(designer.reload.password).to eq encrypted_original_password
        end
      end

      context 'when encrypted password not empty' do
        let(:encrypted_new_password) { 'new_password_hash' }

        it 'does not change encrypted password' do
          put :update, id: designer.id, designer: designer.attributes.merge(password: encrypted_new_password)
          expect(designer.reload.password).to eq encrypted_original_password
        end
      end
    end

    context 'when changing plain password' do
      context 'when plain password is empty' do
        let(:new_password) { '  ' }
        let(:encrypted_new_password) { designer.encrypt(new_password) }

        it 'does not change plain password' do
          put :update, id: designer.id, designer: designer.attributes.merge(plain_password: new_password)
          expect(designer.reload.plain_password).to eq original_password
        end

        it 'does not change encrypted password' do
          put :update, id: designer.id, designer: designer.attributes.merge(plain_password: new_password)
          expect(designer.reload.password).to eq encrypted_original_password
        end
      end

      context 'when plain password not empty' do
        let(:new_password) { '1234' }
        let(:encrypted_new_password) { Designer.encrypt(new_password) }

        it 'changes plain password' do
          put :update, id: designer.id, designer: designer.attributes.merge(plain_password: new_password)
          expect(designer.reload.plain_password).to eq new_password
        end

        it 'changes encrypted password' do
          put :update, id: designer.id, designer: designer.attributes.merge(plain_password: new_password)
          expect(designer.reload.password).to eq encrypted_new_password
        end
      end
    end
  end

end

