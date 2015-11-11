require 'rails_helper'

RSpec.describe UserMailer do
  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer, status: 'submitted') }

  describe 'mailer' do
    it 'send email with welcoming to client' do
      expect(UserMailer.client_registered(client)).to be_present
    end

    it 'sends email with welcoming to designer' do
      expect(UserMailer.designer_registered(designer)).to be_present
    end

    it 'send email about designer registration to owner' do
      expect(UserMailer.user_registration_info(designer)).to be_present
    end

    it 'sends email about client registration to owner' do
      expect(UserMailer.user_registration_info(client)).to be_present
    end

    it 'sends email about invitation to contest to designer' do
      expect(UserMailer.invite_to_contest(designer, client)).to be_present
    end

    it 'sends email about password reset' do
      expect(UserMailer.reset_password(designer, 'password')).to be_present
    end

    it 'sends autorespond about beta signup' do
      expect(UserMailer.sign_up_beta_autoresponder('email')).to be_present
    end

    it 'sends invitation to leave a feedback' do
      expect(UserMailer.invitation_to_leave_a_feedback({username: 'username', email: 'email'}, 'url', client, 'example.com')).to be_present
    end

    it 'sends email about new concept board received' do
      expect(UserMailer.concept_board_received(contest_request)).to be_present
    end

    it 'sends email about product list items marked' do
      expect(UserMailer.product_list_feedback({username: 'username', email: 'email'}, contest_request.id)).to be_present
    end

    it 'sends email about new concept board comment' do
      %w(designer client).each do |role|
        expect(UserMailer.comment_on_board({ username: 'John Doe', email: 'johnD@example.com', role: role, comment: 'text'}, contest_request.id)).to be_present
      end
    end

    it 'sends email clients comment to designer' do
      expect(UserMailer.note_to_concept_board({username: 'username',
                                               email: 'email',
                                               comment: 'text of comment',
                                               client_name: 'client\'s name'})).to be_present
    end

    it 'sends email new product list items' do
      expect(UserMailer.new_product_list_item({username: 'username', email: 'email'})).to be_present
    end

    it 'sends email designer\'s win' do
      expect(UserMailer.notify_designer_about_win(contest_request)).to be_present
    end

    it 'sends email about winner selection' do
      expect(UserMailer.please_pick_winner(contest)).to be_present
    end

    it 'sends email to remind about picking a winner' do
      expect(UserMailer.remind_about_picking_winner(contest)).to be_present
    end

    it 'sends email about winner picked' do
      expect(UserMailer.client_has_picked_a_winner(contest_request)).to be_present
    end

    it 'sends email to designer about client ready for final design' do
      contest_request
      expect(UserMailer.client_hasnt_picked_a_winner_to_designers(contest)).to be_present
    end

    it 'sends email to client about final design submitted' do
      contest_request
      expect(UserMailer.designer_submitted_final_design(contest_request)).to be_present
    end

    it 'sends email to client about no concept boards received in three days' do
      expect(UserMailer.no_concept_boards_received_after_three_days(contest)).to be_present
    end

    it 'sends email to client about last day to choose winner' do
      expect(UserMailer.one_day_left_to_choose_a_winner(contest)).to be_present
    end

    it 'sends email to designers about last day to submit design' do
      expect(UserMailer.one_day_left_to_submit_concept_board(contest)).to be_present
    end

    it 'sends email to designers about 4 days left to submit concept board' do
      expect(UserMailer.four_days_left_to_submit_concept_board(contest)).to be_present
    end

    it 'sends email to client about contest noy live yet' do
      expect(UserMailer.contest_not_live_yet(contest)).to be_present
    end

    it 'sends email to client about designer asked question in contest request' do
      mail_options = { comment_text: 'comment',
                       client: client,
                       contest_request: contest_request }
      expect(UserMailer.designer_asks_client_a_question_submission_phase(mail_options)).to be_present
    end

    it 'sends email to client about account creation' do
      expect(UserMailer.account_creation(client)).to be_present
    end

    it 'sends email to all designers when new contest has been added' do
      designer
      expect(UserMailer.new_project_on_the_platform(Designer.active)).to be_present
    end

    it 'sends email to designers about no submissions for client so far' do
      expect(UserMailer.to_designers_client_no_submissions(contest)).to be_present
    end

    it 'sends email to designers about only one submission for client so far' do
      expect(UserMailer.to_designers_one_submission_only(contest)).to be_present
    end

  end

end
