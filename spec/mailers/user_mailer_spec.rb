require 'rails_helper'

RSpec.describe UserMailer do
  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer) }

  it 'creates client welcoming mail' do
    expect(UserMailer.client_registered(client)).to be_present
  end

  it 'creates designer welcoming mail' do
    expect(UserMailer.designer_registered(designer)).to be_present
  end

  it 'creates designer registration info mail' do
    expect(UserMailer.user_registration_info(designer)).to be_present
  end

  it 'creates client registration info mail' do
    expect(UserMailer.user_registration_info(client)).to be_present
  end

  it 'creates invitation to contest mail' do
    expect(UserMailer.invite_to_contest(designer, client)).to be_present
  end

  it 'creates mail about password reset' do
    expect(UserMailer.reset_password(designer, 'password')).to be_present
  end

  it 'creates mail with autorespond about beta signup' do
    expect(UserMailer.sign_up_beta_autoresponder('email')).to be_present
  end

  it 'creates mail with invitation to leave a feedback' do
    expect(UserMailer.invitation_to_leave_a_feedback({username: 'username', email: 'email'}, 'url', client, 'example.com')).to be_present
  end

  it 'creates mail about new concept board received' do
    expect(UserMailer.concept_board_received(contest_request)).to be_present
  end

  it 'creates mail about mark product list items' do
    expect(UserMailer.product_list_feedback({username: 'username', email: 'email'}, contest_request.id)).to be_present
  end

  it 'creates mail about new concept board comment' do
    %w(designer client).each do |role|
      expect(UserMailer.comment_on_board({ username: 'John Doe', email: 'johnD@example.com', role: role}, contest_request.id)).to be_present
    end
  end

  it 'creates mail about clients comment to designer' do
    expect(UserMailer.note_to_concept_board({username: 'username', email: 'email'})).to be_present
  end

  it 'creates mail about new product list items' do
    expect(UserMailer.new_product_list_item({username: 'username', email: 'email'})).to be_present
  end

  it 'creates mail about designer\'s win' do
    expect(UserMailer.notify_designer_about_win(contest_request)).to be_present
  end
end
