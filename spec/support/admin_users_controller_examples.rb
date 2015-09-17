RSpec.shared_examples 'admin users controller' do |model_symbol|
  include Devise::TestHelpers

  let(:original_password) { Client.encrypt('password') }
  let(model_symbol) { Fabricate(model_symbol, password: original_password) }

  describe 'PATCH update' do
    before do
      sign_in Fabricate(:admin_user)
    end

    context 'new password empty' do
      let(:new_password_hash) { '  ' }

      it 'does not change password' do
        put :update, id: send(model_symbol).id,  model_symbol => send(model_symbol).attributes.merge(password: new_password_hash)
        expect(send(model_symbol).reload.password).to eq original_password
      end
    end

    context 'new password not empty' do
      let(:new_password_hash) { 'new_password_hash' }

      it 'changes password' do
        put :update, id: send(model_symbol).id, model_symbol => send(model_symbol).attributes.merge(password: new_password_hash)
        expect(send(model_symbol).reload.password).to eq new_password_hash
      end
    end
  end

end
