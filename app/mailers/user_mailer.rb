class UserMailer < ActionMailer::Base
  include AbstractController::Callbacks

  include MandrillMailer
  include Rails.application.routes.url_helpers

  MANDRILL_TEMPLATES = {
      client_registered: {
          template: 'new-client-welcome-mail',
          description: { recipients: 'client',
                         recipients_roles: [Client],
                         occurrence: 'registered after intake form completed (not with fast email/facebook signup)'} },
      designer_registered: {
          template: 'user-registration',
          description: { recipients: 'designer',
                         recipients_roles: [Designer],
                         occurrence: 'at creation of designer account'} },
      client_registration_info: {
          template: 'client-registration-info',
          description: { recipients: 'owner',
                         occurrence: 'client have submitted /payment_details page'} },
      designer_registration_info: {
        template: 'designer-registration-info',
        description: { recipients: 'owner',
                       occurrence: 'at creation of designer account'} },
      invite_to_contest: {
        template: 'invite-to-contest',
        description: { recipients: 'designer',
                       recipients_roles: [Designer],
                       occurrence: 'invited to a contest'} },
      reset_password: {
        template: 'reset-password',
        description: { recipients: 'client/designer',
                       recipients_roles: [Client, Designer],
                       occurrence: 'user submitted the form on retry password page'} },
      sign_up_beta_autoresponder: {
        template: 'sign-up-beta-autoresponder',
        description: { recipients: '',
                       occurrence: '[not used anymore]'} },
      notify_about_new_subscriber: {
        template: 'new-beta-subscriber',
        description: { recipients: '',
                       occurrence: '[not used anymore]'} },
      product_list_feedback: {
        template: 'product-list-feedback',
        description: { recipients: 'designer',
                       recipients_roles: [Designer],
                       occurrence: 'one minute after last mark of a product item from client'} },
      invitation_to_leave_a_feedback: {
        template: 'invitation-to-leave-a-feedback',
        description: { recipients: 'to guest',
                      occurrence: 'client have invited a reviewer to help choose a winner'} },
      concept_board_received: {
        template: 'generic-notification',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'designer has submitted a concept board'} },
      comment_on_board: {
        template: 'comment-on-board',
        description: { recipients: 'client/designer',
                       recipients_roles: [Client, Designer],
                       occurrence: 'one minute after client/designer made last comment'} },
      note_to_concept_board: {
        template: 'note-to-concept-board',
        description: { recipients: 'designers (who have submitted concept board or asked a question)',
                       recipients_roles: [Designer],
                       occurrence: 'one minute after client has posted last comment to all designers'} },
      new_product_list_item: {
        template: 'new-product-list-item',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'designer has published product list'} },
      notify_designer_about_win: {
        template: 'winner-designer',
        description: { recipients: 'designer',
                       recipients_roles: [Designer],
                       occurrence: 'the designer\'s concept board won'} },
      notify_product_owner_about_designer_win: {
        template: 'designer-winner-send-update',
        description: { recipients: 'owner',
                       occurrence: 'the designer\'s concept board won'} },
      please_pick_winner: {
        template: 'client-must-pick-a-winner',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'winner_selection milestone has started'} },
      remind_about_picking_winner: {
        template: 'client-hasn-t-picked-a-winner',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'winner selection milestone ended'} },
      client_has_picked_a_winner: {
        template: 'client-has-picked-a-winner',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'the client has selected winner'} },
      client_ready_for_final_design: {
        template: 'client-ready-for-final-design',
        description: { recipients: 'designer',
                       recipients_roles: [Designer],
                       occurrence: 'client approved product list and moved the contest to final phase'} },
      client_hasnt_picked_a_winner_to_designers: {
        template: 'client-hasn-t-picked-a-winner-to-designers',
        description: { recipients: 'designers (who submitted a concept board)',
                       recipients_roles: [Designer],
                       occurrence: 'winner selection milestone ended'} },
      designer_submitted_final_design: {
        template: 'designer-submitted-final-design',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'designer has finished concept board'} },
      no_concept_boards_received_after_three_days: {
        template: 'no-concept-boards-received-after-three-days',
        description: { recipients: 'client',
                       occurrence: 'no concept boards 3 days after contest went live'} },
      one_day_left_to_choose_a_winner: {
        template: 'one-day-left-to-choose-a-winner',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: '1 day left before end of winner selection milestone'} },
      one_day_left_to_submit_concept_board: {
        template: 'one-day-left-to-submit-concept-board',
        description: { recipients: 'designers (every one who have not submitted a concept board yet)',
                       recipients_roles: [Designer],
                       occurrence: '1 day left before end of submission milestone'} },
      four_days_left_to_submit_concept_board: {
        template: 'four-days-left-to-submit-concept-board',
        description: { recipients: 'designers (every one who have not submitted a concept board yet)',
                       recipients_roles: [Designer],
                       occurrence: '4 day left before end of submission milestone'} },
      contest_not_live_yet: {
        template: 'contest-not-live-yet',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'client submitted payment details but the contest brief is not yet completed'} },
      account_creation: {
        template: 'account-creation',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'registered with fast signup'} },
      new_project_on_the_platform: {
        template: 'new-project-on-the-platform',
        description: { recipients: 'designers (all)',
                       recipients_roles: [Designer],
                       occurrence: 'a contest went live (submission started)'} },
      to_designers_one_submission_only: {
        template: 'to-designers-one-submission-only',
        description: { recipients: 'designers (all who haven\'t submitted for the contest)',
                       recipients_roles: [Designer],
                       occurrence: '4 days before end of submission if only one designer has submitted a concept board'} },
      to_designers_client_no_submissions: {
        template: 'to-designers-client-no-submissions-1',
        description: { recipients: 'designers (all who haven\'t submitted for the contest)',
                       recipients_roles: [Designer],
                       occurrence: '4 days before end of submission if no one has submitted a concept board'} },
      client_moved_to_final_design: {
        template: 'client-ready-for-final-design-1',
        description: { recipients: 'owner',
                       occurrence: 'client approved product list and moved the contest to final phase'} },
      new_project_to_hello: {
        template: 'new-project-to-hello',
        description: { recipients: 'owner',
                       occurrence: 'a contest went live (submission started)'} },
      designer_waiting_for_feedback_to_client: {
        template: 'designer-waiting-for-feedback-to-client',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'designer commented concept board 3 days after the last visit of the client and if client has not been notificated with a reminder yet'} },
      realtor_signup: {
        template: 'realtor-signup',
        description: { recipients: 'owner',
                       occurrence: 'new realtor contact'} },
      new_client_no_photos: {
          template: 'new-client-no-photos',
          description: { recipients: 'client',
                         recipients_roles: [Client],
                         occurrence: 'client has provided credit card details but contest brief is not yet completed' }
      },
      hours_added_to_client_project: {
        template: 'hours-added-to-client-project',
        description: { recipients: 'client',
                       recipients_roles: [Client],
                       occurrence: 'designer has recommended a bundle of hours for client to purchase' }
      },
      client_bought_hours_start_designing: {
        template: 'client-bought-hours-start-designing',
        description: { recipients: 'designer',
                       recipients_roles: [Designer],
                       occurrence: 'client has has added hours to designer\'s project' }
      }
  }

  before_filter :set_template

  def client_registered(client_id, email_id = nil)
    client = Client.find(client_id)
    set_template_values(login_link: renderer.client_login_sessions_url,
                        submission_days: ContestMilestone::DAYS['submission'])
    mail to: [wrap_recipient(client, 'to')], email_id: email_id
  end

  def designer_registered(designer_id, email_id = nil)
    designer = Designer.find(designer_id)
    set_template_values(mail_link: renderer.mail_to(I18n.t('registration.mail_to')))
    mail to: [wrap_recipient(designer, 'to')], email_id: email_id
  end

  def client_registration_info(client_id, email_id = nil)
    client = Client.find(client_id)
    set_template_values(client_id: client_id,
                        name: client.name,
                        email: client.email,
                        phone: client.phone_number || '')
    mail to: [wrap_recipient(contact_email, '', 'to')], email_id: email_id
  end

  def designer_registration_info(designer_id, email_id = nil)
    designer = Designer.find(designer_id)
    set_template_values(set_user_params(designer))
    mail to: [wrap_recipient(contact_email, '', 'to')], email_id: email_id
  end

  def invite_to_contest(designer, client, email_id = nil)
    set_template_values(
      client_name: client.name,
      designer_login_url: renderer.designer_login_sessions_url
    )
    mail to: [wrap_recipient(designer, 'to')], email_id: email_id
  end

  def reset_password(user_id, user_role, password, email_id = nil)
    user = user_role.constantize.find(user_id)
    set_template_values(name: user.name,
                        email: user.email,
                        password: password)
    mail({to: [wrap_recipient(user, 'to')], email_id: email_id})
  end

  def sign_up_beta_autoresponder(email, email_id = nil)
    mail to: [wrap_recipient(email, '', 'to')], email_id: email_id
  end

  def notify_about_new_subscriber(beta_subscriber, email_id = nil)
    return unless Rails.env.production?
    set_template_values(new_subscriber_params(beta_subscriber))
    recipients = Settings.beta_notification_emails.map do |email|
      wrap_recipient(email, 'InteriorCrowd', 'to')
    end
    mail to: recipients, email_id: email_id
  end

  def product_list_feedback(designer_id, contest_request_id, email_id = nil)
    designer = Designer.find(designer_id)
    set_template_values(
      edit_response_url: renderer.edit_designer_center_response_url(contest_request_id),
      faq_url: renderer.faq_url(anchor: 'designer'),
      email_link: renderer.mail_to(I18n.t('registration.mail_to'))
    )
    mail to: [wrap_recipient(designer, 'to')], email_id: email_id
  end

  def invitation_to_leave_a_feedback(params, url, client_name, root_url, email_id = nil)
    set_template_values(
      client_name: client_name,
      root_url: root_url,
      contest_url: url
    )
    mail to: [wrap_recipient(params[:email], params[:username], 'to')], email_id: email_id
  end

  def concept_board_received(contest_request, email_id = nil)
    client = contest_request.contest.client
    set_template_values(
        client_center_entries_url: renderer.client_center_entries_url,
        faq_url: renderer.faq_url(anchor: 'client'),
        mail_link: renderer.mail_to(I18n.t('registration.mail_to'))
    )
    mail to: [wrap_recipient(client, 'to')], email_id: email_id
  end

  def comment_on_board(params, contest_request_id, email_id = nil)
    recipient = params[:recipient_role].constantize.find(params[:recipient_id])
    author = params[:author_role].constantize.find(params[:author_id])
    comment = ConceptBoardComment.find(params[:comment_id])
    comment_text = ERB::Util.html_escape(comment.text).split("\n").join("<br/>")
    set_template_values(reply_delimiter: Griddler.configuration.reply_delimiter,
                        comment_text: comment_text,
                        comment_author_role: params[:author_role].downcase,
                        project_url: url_for_comment_on_board(params[:author_role].downcase, contest_request_id)
    )
    concept_board_comment_email = ConceptBoardCommentEmail.new(comment)
    message_options(headers: concept_board_comment_email.headers)
    mail to: [wrap_recipient(recipient, 'to')],
         email_id: email_id
  end

  def note_to_concept_board(params, email_id = nil)
    designer = Designer.find(params[:designer_id])
    set_template_values(
        client_name: params[:client_name],
        comment: ERB::Util.html_escape(params[:comment]).split("\n").join("<br/>").html_safe,
        updates_url: renderer.designer_center_updates_url
    )
    mail to: [wrap_recipient(designer, 'to')], email_id: email_id
  end

  def new_product_list_item(client_id, email_id = nil)
    client = Client.find(client_id)
    set_template_values(
      client_center_entries_url: renderer.client_center_entries_url,
      faq_url: renderer.faq_url(anchor: 'client'),
      mail_link: renderer.mail_to(I18n.t('registration.mail_to'))
    )
    mail to: [wrap_recipient(client, 'to')], email_id: email_id
  end

  def notify_designer_about_win(request_id, email_id = nil)
    contest_request = ContestRequest.find request_id
    designer = contest_request.designer
    contest = contest_request.contest
    client = contest.client
    set_template_values(
        contest_url: renderer.designer_center_contest_url(id: contest.id),
        contest_name: contest.name,
        client_name: client.name
    )
    mail to: [wrap_recipient(designer, 'to')], email_id: email_id
  end

  def notify_product_owner_about_designer_win(request_id, email_id = nil)
    contest_request = ContestRequest.find request_id
    designer = contest_request.designer
    contest = contest_request.contest
    client = contest.client
    set_template_values(
        name: designer.name,
        email: designer.email,
        winner_id: designer.id,
        datetime: contest_request.won_at,
        contest_id: contest.id,
        client_name: client.name
    )
    mail to: [wrap_recipient(Settings.winning_designers_notification_email, '', 'to')], email_id: email_id
  end

  def please_pick_winner(contest, email_id = nil)
    client = contest.client
    set_template_values(
        days_to_pick_winner: ContestMilestone::DAYS['winner_selection'],
        entries_url: renderer.client_center_entries_url,
        client_faq_url: renderer.faq_url(anchor: 'client'),
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client, 'to')], email_id: email_id)
  end

  def remind_about_picking_winner(contest, email_id = nil)
    client = contest.client
    set_template_values(
        entries_url: renderer.client_center_entries_url,
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client, 'to')], email_id: email_id)
  end

  def client_has_picked_a_winner(contest_request_id, email_id = nil)
    contest_request = ContestRequest.find contest_request_id
    client = contest_request.contest.client
    set_template_values(
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client, 'to')], email_id: email_id)
  end

  def client_ready_for_final_design(contest_request_id, email_id = nil)
    contest_request = ContestRequest.find(contest_request_id)
    client = contest_request.contest.client
    designer = contest_request.designer
    set_template_values(
        client_name: client.name
    )
    mail(to: [wrap_recipient(designer, 'to')], email_id: email_id)
  end

  def client_hasnt_picked_a_winner_to_designers(contest, email_id = nil)
    designers = Designer.joins(:contest_requests).where(contest_requests: { id: contest.requests.submitted.pluck(:id) })
    set_template_values(
        contest_name: contest.name
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer, 'to') }, email_id: email_id)
  end

  def designer_submitted_final_design(contest_request, email_id = nil)
    client = contest_request.contest.client
    set_template_values(
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client, 'to')], email_id: email_id)
  end

  def no_concept_boards_received_after_three_days(contest, email_id = nil)
    client = contest.client
    mail(to: [wrap_recipient(client, 'to'),
              wrap_recipient(contact_email, 'InteriorCrowd', 'to')],
         email_id: email_id)
  end

  def one_day_left_to_choose_a_winner(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    client = contest.client
    set_template_values(
        hello_address: contact_email,
        client_name: client.name,
        entries_url: renderer.client_center_entries_url,
        client_faq_url: renderer.faq_url(anchor: 'client')
    )
    mail(to: [wrap_recipient(client, 'to')], email_id: email_id)
  end

  def one_day_left_to_submit_concept_board(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        contest_name: contest.name,
        new_contests_url: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer, 'to') }, email_id: email_id)
  end

  def four_days_left_to_submit_concept_board(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        contest_name: contest.name,
        new_contests_url: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer, 'to') }, email_id: email_id)
  end

  def contest_not_live_yet(contest_id, email_id = nil)
    set_template_values(
        entries_url: renderer.client_center_entries_url,
        pictures_email: 'pictures@interiorcrowd.com'
    )
    contest = Contest.find(contest_id)
    client = contest.client
    mail(to: [wrap_recipient(client, 'to')], email_id: email_id)
  end

  def account_creation(client_id, email_id = nil)
    client = Client.find(client_id)
    set_template_values(
        twitter_url: Settings.external_urls.social.twitter,
        twitter_icon_url: asset_url('/icons/twitter.png'),
        facebook_url: Settings.external_urls.social.facebook,
        facebook_icon_url: asset_url('/icons/facebook.png'),
        pinterest_url: Settings.external_urls.social.pinterest,
        pinterest_icon_url: asset_url('/icons/pinterest.png'),
        instagram_url: Settings.external_urls.social.instagram,
        instagram_icon_url: asset_url('/icons/instagram.png'),
        logo_url: asset_url('/logo.png'),
        brief_url: renderer.design_brief_contests_url,
        terms_of_service_url: renderer.terms_of_service_url,
        privacy_policy_url: renderer.privacy_policy_url,
        unsubscribe_url: renderer.unsubscribe_clients_url(signature: client.access_token),
        promocode_background_url: asset_url('/emails/back.png'),
        step_one_icon_url: asset_url('/emails/step_one.png'),
        step_two_icon_url: asset_url('/emails/step_two.png'),
        step_three_icon_url: asset_url('/emails/step_three.png')
    )
    mail(to: [wrap_recipient(client, 'to')], email_id: email_id)
  end

  def new_project_on_the_platform(client_name, project_name, designer_ids, email_id = nil)
    set_template_values(
        client_name: client_name.present? ? client_name : 'A new client',
        project_name: project_name,
        login_url: designer_login_sessions_url
    )
    recipients = Designer.where(id: designer_ids).map do |designer|
      wrap_recipient(designer, 'to')
    end
    mail to: recipients, email_id: email_id
  end

  def to_designers_one_submission_only(contest_id, email_id = nil)
    mail_about_contest_submissions(contest_id, email_id)
  end

  def to_designers_client_no_submissions(contest_id, email_id = nil)
    mail_about_contest_submissions(contest_id, email_id)
  end

  def client_moved_to_final_design(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    client = contest.client
    set_template_values(
        client_name: client.name,
        client_admin_url: renderer.admin_client_url(client.id),
        client_id: client.id,
        client_email: client.email
    )
    mail to: [wrap_recipient(Settings.info_email, '', 'to')], email_id: email_id
  end

  def new_project_to_hello(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    client = contest.client
    set_template_values(
        client_name: client.name,
        client_id: client.id
    )
    mail to: [wrap_recipient(Settings.info_email, '', 'to')], email_id: email_id
  end

  def designer_waiting_for_feedback_to_client(client_id, contest_ids, email_id = nil)
    client = Client.find(client_id)
    set_template_values(
      contest_url: renderer.client_center_entry_url(id: contest_ids[0])
    )
    mail(to: [wrap_recipient(client, 'to')], email_id: email_id)
  end

  def realtor_signup(realtor_contact_id, email_id = nil)
    realtor_contact = RealtorContact.find(realtor_contact_id)
    set_template_values(
      name: realtor_contact.name,
      brokerage: realtor_contact.brokerage,
      email: realtor_contact.email,
      phone: realtor_contact.phone,
      choice: realtor_contact.choice
    )
    mail to: [wrap_recipient(Settings.info_email, '', 'to')], email_id: email_id
  end

  def new_client_no_photos(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    client = contest.client
    set_template_values(
      entries_url: renderer.client_center_entries_url,
      pictures_email: Settings.pictures_email,
      submission_days: ContestMilestone::DAYS['submission'],
      login_link: renderer.client_center_entries_url
    )
    mail to: [wrap_recipient(client, 'to')], email_id: email_id
  end

  def hours_added_to_client_project(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    client = contest.client
    set_template_values(
      client_time_tracker_url: renderer.time_tracker_client_center_entry_url(id: contest.id)
    )
    mail to: [wrap_recipient(client, 'to')], email_id: email_id
  end

  def client_bought_hours_start_designing(contest_request_id, email_id = nil)
    contest_request = ContestRequest.find(contest_request_id)
    designer = contest_request.designer
    contest = contest_request.contest
    client = contest.client
    set_template_values(
      project_time_tracker_url: renderer.designer_center_contest_time_tracker_url(contest_id: contest.id),
      client_name: client.name
    )
    mail to: [wrap_recipient(designer, 'to')], email_id: email_id
  end

  private

  def asset_url(asset_path)
    root_url + '/assets' + asset_path
  end

  def set_user_params(user)
    {
      role: user.role.downcase,
      name: user.name,
      email: user.email,
      phone: user.phone_number || ''
    }
  end

  def wrap_recipient(*args)
    if args.length == 2
      user, type = args
      role = user.role
      email = user.email
      name = user.name
    elsif args.length == 3
      email, name, type = args
      role = nil
    end
    { email: email, name: name, type: type, role: role }.compact
  end

  def new_subscriber_params(beta_subscriber)
    { email: beta_subscriber.email, name: beta_subscriber.name, role: beta_subscriber.role }
  end

  def url_for_comment_on_board(user_role, contest_request_id)
    return designer_center_response_url(contest_request_id) if user_role == 'client'
    client_center_entries_url
  end

  def contact_email
    Settings.info_email
  end

  def renderer
    @renderer ||= RenderingHelper.new
  end

  def mail_about_contest_submissions(contest_id, email_id)
    contest = Contest.find(contest_id)
    client = contest.client
    designers = contest.not_submitted_designers
    set_template_values(
    client_name: client.name,
        contest_name: contest.name,
        contest_url: designer_center_contest_url(id: contest.id)
    )
    recipients = designers.map do |designer|
      wrap_recipient(designer, 'to')
    end
    mail to: recipients, email_id: email_id
  end

  def set_template
    template MANDRILL_TEMPLATES[action_name.to_sym][:template]
  end

end
