class UserMailer < ActionMailer::Base
  include AbstractController::Callbacks

  include MandrillMailer
  include Rails.application.routes.url_helpers
  MANDRILL_TEMPLATES = {
      client_registered: 'new-client-welcome-mail',
      designer_registered: 'user-registration',
      client_registration_info: 'client-registration-info',
      designer_registration_info: 'designer-registration-info',
      invite_to_contest: 'invite-to-contest',
      reset_password: 'reset-password',
      sign_up_beta_autoresponder: 'sign-up-beta-autoresponder',
      notify_about_new_subscriber: 'new-beta-subscriber',
      product_list_feedback: 'product-list-feedback',
      invitation_to_leave_a_feedback: 'invitation-to-leave-a-feedback',
      concept_board_received: 'generic-notification',
      comment_on_board: 'comment-on-board',
      note_to_concept_board: 'note-to-concept-board',
      new_product_list_item: 'new-product-list-item',
      notify_designer_about_win: 'Winner_designer',
      please_pick_winner: 'client-must-pick-a-winner',
      remind_about_picking_winner: 'client-hasn-t-picked-a-winner',
      client_has_picked_a_winner: 'client-has-picked-a-winner',
      client_ready_for_final_design: 'client-ready-for-final-design',
      client_hasnt_picked_a_winner_to_designers: 'client-hasn-t-picked-a-winner-to-designers',
      designer_submitted_final_design: 'designer-submitted-final-design',
      no_concept_boards_received_after_three_days: 'no-concept-boards-received-after-three-days',
      one_day_left_to_choose_a_winner: 'one-day-left-to-choose-a-winner',
      one_day_left_to_submit_concept_board: 'one-day-left-to-submit-concept-board',
      four_days_left_to_submit_concept_board: 'four-days-left-to-submit-concept-board',
      contest_not_live_yet: 'contest-not-live-yet',
      designer_asks_client_a_question_submission_phase: 'designer-asks-client-a-question-submission-phase',
      account_creation: 'account-creation',
      new_project_on_the_platform: 'new-project-on-the-platform',
      to_designers_one_submission_only: 'to-designers-one-submission-only',
      to_designers_client_no_submissions: 'to-designers-client-no-submissions-1',
      client_moved_to_final_design: 'client-ready-for-final-design-1',
      new_project_to_hello: 'new-project-to-hello',
      designer_waiting_for_feedback_to_client: 'designer-waiting-for-feedback-to-client',
      realtor_signup: 'realtor-signup'
  }

  before_filter :set_template

  def client_registered(client_id, email_id = nil)
    client = Client.find(client_id)
    set_template_values(login_link: renderer.client_login_sessions_url,
                        submission_days: ContestMilestone::DAYS['submission'])
    mail to: [wrap_recipient(client.email, client.first_name, 'to')], email_id: email_id
  end

  def designer_registered(designer_id, email_id = nil)
    designer = Designer.find(designer_id)
    subject = I18n.t('mails.designer_registration.subject')
    set_template_values(mail_link: renderer.mail_to(I18n.t('registration.mail_to')))
    mail to: [wrap_recipient(designer.email, designer.first_name, 'to')], subject: subject, email_id: email_id
  end

  def client_registration_info(client_id, email_id = nil)
    client = Client.find(client_id)
    set_template_values(set_user_params(client))
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
    mail to: [wrap_recipient(designer.email, designer.name, 'to')], email_id: email_id
  end

  def reset_password(user_id, user_role, password, email_id = nil)
    user = user_role.constantize.find(user_id)
    set_template_values(name: user.name,
                        email: user.email,
                        password: password)
    mail({to: [wrap_recipient(user.email, user.name, 'to')], email_id: email_id})
  end

  def sign_up_beta_autoresponder(email, email_id = nil)
    subject = I18n.t('mails.beta_autorespond.subject')
    mail to: [wrap_recipient(email, '', "to")], subject:subject, email_id: email_id
  end

  def notify_about_new_subscriber(beta_subscriber, email_id = nil)
    return unless Rails.env.production?
    set_template_values(new_subscriber_params(beta_subscriber))
    recipients = Settings.beta_notification_emails.map do |email|
      wrap_recipient(email, 'InteriorCrowd', 'to')
    end
    mail to: recipients, subject: I18n.t('mails.beta_subscriber.subject'), email_id: email_id
  end

  def product_list_feedback(params, contest_request_id, email_id = nil)
    set_template_values(
      edit_response_url: renderer.edit_designer_center_response_url(contest_request_id),
      faq_url: renderer.faq_url(anchor: 'designer'),
      email_link: renderer.mail_to(I18n.t('registration.mail_to'))
    )
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t('mails.product_list_feedback.subject'), email_id: email_id
  end

  def invitation_to_leave_a_feedback(params, url, client_name, root_url, email_id = nil)
    set_template_values(
      client_name: client_name,
      root_url: root_url,
      contest_url: url
    )
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t('mails.invitation_to_leave_feedback.subject', client_name: @client_name), email_id: email_id
  end

  def concept_board_received(contest_request, email_id = nil)
    client = contest_request.contest.client
    email = client.email
    username = client.name
    set_template_values(
        client_center_entries_url: renderer.client_center_entries_url,
        faq_url: renderer.faq_url(anchor: 'client'),
        mail_link: renderer.mail_to(I18n.t('registration.mail_to'))
    )
    mail to: [wrap_recipient(email, username, 'to')],
         subject: I18n.t('mails.concept_board_received.subject'), email_id: email_id
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
    mail to: [wrap_recipient(recipient.email, recipient.name, 'to')],
         email_id: email_id
  end

  def note_to_concept_board(params, email_id = nil)
    set_template_values(
        client_name: params[:client_name],
        comment: ERB::Util.html_escape(params[:comment]).split("\n").join("<br/>").html_safe,
        updates_url: renderer.designer_center_updates_url
    )
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t('mails.note_to_concept_board.subject'), email_id: email_id
  end

  def new_product_list_item(params, email_id = nil)
    set_template_values(
      client_center_entries_url: renderer.client_center_entries_url,
      faq_url: renderer.faq_url(anchor: 'client'),
      mail_link: renderer.mail_to(I18n.t('registration.mail_to'))
    )
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t("mails.new_product_list_item.subject"), email_id: email_id
  end

  def notify_designer_about_win(contest_request, email_id = nil)
    designer = contest_request.designer
    contest = contest_request.contest
    client = contest.client
    set_template_values(
        hello_address: contact_email,
        contest_url: renderer.designer_center_contest_url(id: contest.id),
        contest_name: contest.name,
        client_name: client.name
    )
    mail to: [wrap_recipient(designer.email, designer.name, 'to')], email_id: email_id
  end

  def please_pick_winner(contest, email_id = nil)
    client = contest.client
    set_template_values(
        days_to_pick_winner: ContestMilestone::DAYS['winner_selection'],
        entries_url: renderer.client_center_entries_url,
        client_faq_url: renderer.faq_url(anchor: 'client'),
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def remind_about_picking_winner(contest, email_id = nil)
    client = contest.client
    set_template_values(
        entries_url: renderer.client_center_entries_url,
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def client_has_picked_a_winner(contest_request, email_id = nil)
    client = contest_request.contest.client
    set_template_values(
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def client_ready_for_final_design(contest_request, email_id = nil)
    client = contest_request.contest.client
    designer = contest_request.designer
    set_template_values(
        client_name: client.name
    )
    mail(to: [wrap_recipient(designer.email, designer.name, 'to')], email_id: email_id)
  end

  def client_hasnt_picked_a_winner_to_designers(contest, email_id = nil)
    designers = Designer.joins(:contest_requests).where(contest_requests: { id: contest.requests.submitted.pluck(:id) })
    set_template_values(
        contest_name: contest.name
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def designer_submitted_final_design(contest_request, email_id = nil)
    client = contest_request.contest.client
    set_template_values(
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def no_concept_boards_received_after_three_days(contest, email_id = nil)
    client = contest.client
    mail(to: [wrap_recipient(client.email, client.name, 'to'), wrap_recipient(contact_email, 'InteriorCrowd', 'to')], email_id: email_id)
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
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def one_day_left_to_submit_concept_board(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        contest_name: contest.name,
        new_contests_url: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def four_days_left_to_submit_concept_board(contest_id, email_id = nil)
    contest = Contest.find(contest_id)
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        contest_name: contest.name,
        new_contests_url: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def contest_not_live_yet(contest, email_id = nil)
    set_template_values(
        entries_url: renderer.client_center_entries_url,
        pictures_email: 'pictures@interiorcrowd.com'
    )
    client = contest.client
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def designer_asks_client_a_question_submission_phase(options, email_id = nil)
    comment = ConceptBoardComment.find(options[:comment_id])
    set_template_values(
      entry_url: renderer.contest_request_url(id: comment.contest_request.id),
      comment_text: comment.text,
      reply_delimiter: Griddler.configuration.reply_delimiter
    )
    concept_board_comment_email = ConceptBoardCommentEmail.new(comment)
    message_options(headers: concept_board_comment_email.headers)
    client = Client.find(options[:client_id])
    mail(to: [wrap_recipient(client.email, client.name, 'to')],
         email_id: email_id,
         subject: concept_board_comment_email.subject)
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
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def new_project_on_the_platform(client_name, project_name, designer_ids, email_id = nil)
    set_template_values(
        client_name: client_name.present? ? client_name : 'A new client',
        project_name: project_name,
        login_url: designer_login_sessions_url
    )
    recipients = Designer.where(id: designer_ids).map do |designer|
      wrap_recipient(designer.email, designer.name, 'to')
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
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
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

  private

  def asset_url(asset_path)
    Settings.app_host + '/assets' + asset_path
  end

  def set_user_params(user)
    {
      role: user.role.downcase,
      name: user.name,
      email: user.email,
      phone: user.phone_number || ''
    }
  end

  def set_invitation_params(client)

  end

  def wrap_recipient(email, name, type)
    { email: email, name: name, type: type }
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
      wrap_recipient(designer.email, designer.name, 'to')
    end
    mail to: recipients, email_id: email_id
  end

  def set_template
    template MANDRILL_TEMPLATES[action_name.to_sym]
  end

end
