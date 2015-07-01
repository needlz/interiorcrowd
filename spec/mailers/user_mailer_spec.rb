require 'rails_helper'

RSpec.describe UserMailer do
  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer, status: 'submitted') }

  describe 'mail creation' do
    it 'client welcoming' do
      expect(UserMailer.client_registered(client)).to be_present
    end

    it 'designer welcoming' do
      expect(UserMailer.designer_registered(designer)).to be_present
    end

    it 'designer registration info' do
      expect(UserMailer.user_registration_info(designer)).to be_present
    end

    it 'client registration info' do
      expect(UserMailer.user_registration_info(client)).to be_present
    end

    it 'invitation to contest' do
      expect(UserMailer.invite_to_contest(designer, client)).to be_present
    end

    it 'password reset' do
      expect(UserMailer.reset_password(designer, 'password')).to be_present
    end

    it 'autorespond about beta signup' do
      expect(UserMailer.sign_up_beta_autoresponder('email')).to be_present
    end

    it 'invitation to leave a feedback' do
      expect(UserMailer.invitation_to_leave_a_feedback({username: 'username', email: 'email'}, 'url', client, 'example.com')).to be_present
    end

    it 'new concept board received' do
      expect(UserMailer.concept_board_received(contest_request)).to be_present
    end

    it 'product list items marked' do
      expect(UserMailer.product_list_feedback({username: 'username', email: 'email'}, contest_request.id)).to be_present
    end

    it 'new concept board comment' do
      %w(designer client).each do |role|
        expect(UserMailer.comment_on_board({ username: 'John Doe', email: 'johnD@example.com', role: role, comment: 'text'}, contest_request.id)).to be_present
      end
    end

    it 'clients comment to designer' do
      expect(UserMailer.note_to_concept_board({username: 'username',
                                               email: 'email',
                                               comment: 'text of comment',
                                               client_name: 'client\'s name'})).to be_present
    end

    it 'new product list items' do
      expect(UserMailer.new_product_list_item({username: 'username', email: 'email'})).to be_present
    end

    it 'designer\'s win' do
      expect(UserMailer.notify_designer_about_win(contest_request)).to be_present
    end

    it 'notify about winner selection' do
      expect(UserMailer.please_pick_winner(contest)).to be_present
    end

    it 'remind about picking a winner' do
      expect(UserMailer.remind_about_picking_winner(contest)).to be_present
    end

    it 'winner picked' do
      expect(UserMailer.client_has_picked_a_winner(contest_request)).to be_present
    end

    it 'to designer: client ready for final design' do
      contest_request
      expect(UserMailer.client_hasnt_picked_a_winner_to_designers(contest)).to be_present
    end

    it 'to client: final design submitted' do
      contest_request
      expect(UserMailer.designer_submitted_final_design(contest_request)).to be_present
    end

    it 'to client: no concept boards received in three days' do
      expect(UserMailer.no_concept_boards_received_after_three_days(contest)).to be_present
    end

    it 'to client: last day to choose winner' do
      expect(UserMailer.one_day_left_to_choose_a_winner(contest)).to be_present
    end

    it 'to designer: last day to submit design' do
      expect(UserMailer.one_day_left_to_submit_concept_board(contest)).to be_present
    end
  end

end
