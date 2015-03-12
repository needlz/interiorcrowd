require 'rails_helper'

RSpec.describe UserMailer do

  it 'creates client welcoming mail' do
    client = Fabricate(:client)
    expect(UserMailer.client_registered(client, 'password')).to be_present
  end

  it 'creates designer welcoming mail' do
    designer = Fabricate(:designer)
    expect(UserMailer.designer_registered(designer, 'password')).to be_present
  end

  it 'creates designer registration info mail' do
    designer = Fabricate(:designer)
    expect(UserMailer.designer_registration_info(designer)).to be_present
  end

  it 'creates invitation to contest mail' do
    designer = Fabricate(:designer)
    client = Fabricate(:client)
    expect(UserMailer.invite_to_contest(designer, client)).to be_present
  end

  it 'creates mail about password reset' do
    designer = Fabricate(:designer)
    expect(UserMailer.reset_password(designer, 'password')).to be_present
  end

  it 'creates mail with autorespond about beta signup' do
    expect(UserMailer.sign_up_beta_autoresponder('email')).to be_present
  end

  it 'creates mail with invitation to leave a feedback' do
    expect(UserMailer.invitation_to_leave_a_feedback({username: 'username', email: 'email'}, url: 'url' )).to be_present
  end

end
