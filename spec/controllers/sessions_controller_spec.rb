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
        post :designer_retry_password, email: designer.email
        expect(designer.reload.plain_password).not_to eq(plain_password)
      end

      it 'notify the user about changing email' do
        expect(Jobs::Mailer).to receive(:schedule)
        post :designer_retry_password, email: designer.email
      end
    end
  end

  describe 'GET client_fb_authenticate' do
    let(:valid_oauth_code){ 'valid_oauth_code' }
    let(:valid_access_token){ 'valid_access_token' }
    let(:uid){ 1 }
    let(:client) { Fabricate(:client, facebook_user_id: uid) }

    before do
      @access_token_valid = false
      allow_any_instance_of(Koala::Facebook::OAuth).to receive(:get_access_token) do |oauth, oauth_code|
        if oauth_code == valid_oauth_code
          @access_token_valid = true
          valid_access_token
        end
      end

      allow_any_instance_of(Koala::Facebook::API).to receive(:api) do |action, params_hash|
        if @access_token_valid
          { 'id' => uid }
        else
          {
            'error' => {
              'message' => 'Invalid OAuth access token.',
              'type' => 'OAuthException',
              'code' => 190
            }
          }
        end
      end
    end

    context 'when valid oauth code passed' do
      it 'it logins a client' do
        client
        get :client_fb_authenticate, code: valid_oauth_code
        expect(session[:client_id]).to eq client.id
      end
    end

    context 'when no oauth code passed' do
      it 'does not login client' do
        client
        get :client_fb_authenticate
        expect(session[:client_id]).to be_nil
      end
    end

    context 'when invalid oauth code passed' do
      it 'does not login client' do
        client
        get :client_fb_authenticate, code: 'invalid'
        expect(session[:client_id]).to be_nil
      end
    end
  end

end
