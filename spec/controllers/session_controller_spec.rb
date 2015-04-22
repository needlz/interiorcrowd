require 'rails_helper'

RSpec.describe SessionsController do

  describe 'retry_password' do
    let(:designer) { Fabricate(:designer, plain_password: 'password') }
    let(:client) { Fabricate(:client, plain_password: 'password') }

    describe 'Client' do
      it 'change password for client' do
        plain_password =  client.plain_password
        post :client_retry_password, email: client.email
        expect(client.reload.plain_password).not_to eq(plain_password)
      end

      it 'notify the user about changing email' do
        expect(Jobs::Mailer).to receive(:schedule)
        post :client_retry_password, email: client.email
      end
    end

    describe 'Designer' do
      it 'change password for designer' do
        plain_password =  designer.plain_password
        post :retry_password, email: designer.email
        expect(designer.reload.plain_password).not_to eq(plain_password)
      end

      it 'notify the user about changing email' do
        expect(Jobs::Mailer).to receive(:schedule)
        post :retry_password, email: designer.email
      end
    end

  end

end