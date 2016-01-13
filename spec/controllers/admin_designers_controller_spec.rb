require 'rails_helper'

RSpec.describe Admin::DesignersController, type: :controller do
  include Devise::TestHelpers

  let(:original_password) { Designer.encrypt('password') }
  let(:designer) { Fabricate(:designer, password: original_password) }

  describe 'PATCH update' do
    before do
      sign_in Fabricate(:admin_user)
    end

    context 'new password empty' do
      let(:new_password_hash) { '  ' }

      it 'does not change password' do
        put :update, id: designer.id,  :designer => designer.attributes.merge(password: new_password_hash)
        expect(designer.reload.password).to eq original_password
      end
    end

    context 'new password not empty' do
      let(:new_password_hash) { 'new_password_hash' }

      it 'changes password' do
        put :update, id: designer.id, :designer => designer.attributes.merge(password: new_password_hash)
        expect(designer.reload.password).to eq new_password_hash
      end
    end
  end

end

