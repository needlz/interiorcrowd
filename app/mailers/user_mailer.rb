class UserMailer < ActionMailer::Base
  include MandrillMailer
  include Rails.application.routes.url_helpers

  def client_registered(client, email_id = nil)
    template 'client_welcome_mail'
    set_template_values(login_link: renderer.client_login_sessions_url,
                        submission_days: ContestMilestone::DAYS['submission'])
    mail to: [wrap_recipient(client.email, client.first_name, 'to')], email_id: email_id
  end

  def designer_registered(designer, email_id = nil)
    template 'user_registration'
    subject = I18n.t('mails.designer_registration.subject')
    set_template_values(text: render_to_string('mails/designer_registration'))
    mail to: [wrap_recipient(designer.email, designer.first_name, 'to')], subject: subject, email_id: email_id
  end

  def user_registration_info(user, email_id = nil)
    template "#{ user.role.downcase }_registration_info"
    set_template_values(set_user_params(user))
    mail to: [wrap_recipient(Settings.info_email, '', 'to')], email_id: email_id
  end

  def invite_to_contest(designer, client, email_id = nil)
    template 'invite_to_contest'
    set_template_values(set_invitation_params(client))
    mail to: [wrap_recipient(designer.email, designer.name, 'to')], email_id: email_id
  end

  def reset_password(user, password, email_id = nil)
    template 'reset_password'
    subject = I18n.t('mails.password_reset.subject')
    set_template_values(set_reset_password_params(user, password))
    mail to: [wrap_recipient(user.email, user.name, 'to')], subject:subject, email_id: email_id
  end

  def sign_up_beta_autoresponder(email, email_id = nil)
    template 'sign_up_beta_autoresponder'
    subject = I18n.t('mails.beta_autorespond.subject')
    mail to: [wrap_recipient(email, '', "to")], subject:subject, email_id: email_id
  end

  def notify_about_new_subscriber(beta_subscriber, email_id = nil)
    return unless Rails.env.production?
    template 'new_beta_subscriber'
    set_template_values(new_subscriber_params(beta_subscriber))
    recipients = Settings.beta_notification_emails.map do |email|
      wrap_recipient(email, 'InteriorCrowd', 'to')
    end
    mail to: recipients, subject: I18n.t('mails.beta_subscriber.subject'), email_id: email_id
  end

  def product_list_feedback(params, contest_request_id, email_id = nil)
    template 'product_list_feedback'
    @url = edit_designer_center_response_url(contest_request_id)
    set_template_values(text: render_to_string('mails/product_list_feedback'))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t('mails.product_list_feedback.subject'), email_id: email_id
  end

  def invitation_to_leave_a_feedback(params, url, client, root_url, email_id = nil)
    template 'invitation_to_leave_a_feedback'
    @client_name = client.name
    @page_url = url
    @root_url = root_url
    set_template_values(text: render_to_string('mails/invite_to_leave_feedback'))
    mail to: [wrap_recipient(params['email'], params['username'], 'to')],
         subject: I18n.t('mails.invitation_to_leave_feedback.subject', client_name: @client_name), email_id: email_id
  end

  def concept_board_received(contest_request, email_id = nil)
    client = contest_request.contest.client
    email = client.email
    username = client.name
    template 'generic_notification'
    set_template_values(text: render_to_string('mails/new_concept_board_received'))
    mail to: [wrap_recipient(email, username, 'to')],
         subject: I18n.t('mails.concept_board_received.subject'), email_id: email_id
  end

  def comment_on_board(params, contest_request_id, email_id = nil)
    template 'comment_on_board'
    @url = url_for_comment_on_board(params[:role], contest_request_id)
    @author_name = params[:username]
    @comment = ERB::Util.html_escape(params[:comment]).split("\n").join("<br/>")
    set_template_values(text: render_to_string("mails/#{params[:role]}s_comment_on_board"))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t("mails.#{params[:role]}s_comment_on_board.subject"), email_id: email_id
  end


  def note_to_concept_board(params, email_id = nil)
    template 'note_to_concept_board'
    @url = designer_center_updates_url
    @client_name = params[:client_name]
    @comment = ERB::Util.html_escape(params[:comment]).split("\n").join("<br/>")
    set_template_values(text: render_to_string('mails/note_to_concept_board'))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t('mails.note_to_concept_board.subject'), email_id: email_id
  end

  def new_product_list_item(params, email_id = nil)
    template "new_product_list_item"
    @url = client_center_entries_url
    set_template_values(text: render_to_string("mails/new_product_list_item"))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t("mails.new_product_list_item.subject"), email_id: email_id
  end

  def notify_designer_about_win(contest_request, email_id = nil)
    template 'Winner_designer'
    designer = contest_request.designer
    contest = contest_request.contest
    client = contest.client
    set_template_values(
        HELLO_ADDRESS: contact_email,
        CONTEST_URL: renderer.designer_center_contest_url(id: contest.id),
        CONTEST_NAME: contest.name,
        CLIENT_NAME: client.name
    )
    mail to: [wrap_recipient(designer.email, designer.name, 'to')], email_id: email_id
  end

  def please_pick_winner(contest, email_id = nil)
    template 'client_must_pick_a_winner'
    client = contest.client
    set_template_values(
        DAYS_TO_PICK_WINNER: ContestMilestone::DAYS['winner_selection'],
        ENTRIES_URL: renderer.client_center_entries_url,
        CLIENT_FAQ_URL: renderer.faq_url(anchor: 'client'),
        HELLO_ADDRESS: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def remind_about_picking_winner(contest, email_id = nil)
    template 'client_hasnt_picked_a_winner'
    client = contest.client
    set_template_values(
        ENTRIES_URL: renderer.client_center_entries_url,
        HELLO_ADDRESS: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def client_has_picked_a_winner(contest_request, email_id = nil)
    template 'client_has_picked_a_winner'
    client = contest_request.contest.client
    set_template_values(
        HELLO_ADDRESS: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def client_ready_for_final_design(contest_request, email_id = nil)
    template 'client_ready_for_final_design'
    client = contest_request.contest.client
    designer = contest_request.designer
    set_template_values(
        CLIENT_NAME: client.name
    )
    mail(to: [wrap_recipient(designer.email, designer.name, 'to')], email_id: email_id)
  end

  def client_hasnt_picked_a_winner_to_designers(contest, email_id = nil)
    template 'client_hasnt_picked_a_winner_to_designers'
    designers = Designer.joins(:contest_requests).where(contest_requests: { id: contest.requests.submitted.pluck(:id) })
    set_template_values(
        CONTEST_NAME: contest.name
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def designer_submitted_final_design(contest_request, email_id = nil)
    template 'Designer_submitted_final_design'
    client = contest_request.contest.client
    set_template_values(
        HELLO_ADDRESS: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def no_concept_boards_received_after_three_days(contest, email_id = nil)
    template 'No_concept_boards_received_after_three_days'
    client = contest.client
    mail(to: [wrap_recipient(client.email, client.name, 'to'), wrap_recipient(contact_email, 'InteriorCrowd', 'to')], email_id: email_id)
  end

  def one_day_left_to_choose_a_winner(contest, email_id = nil)
    template 'One_day_left_to_choose_a_winner'
    client = contest.client
    set_template_values(
        HELLO_ADDRESS: contact_email,
        CLIENT_NAME: client.name,
        ENTRIES_URL: renderer.client_center_entries_url,
        CLIENT_FAQ_URL: renderer.faq_url(anchor: 'client')
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def one_day_left_to_submit_concept_board(contest, email_id = nil)
    template 'One_day_left_to_submit_concept_board'
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        CONTEST_NAME: contest.name,
        NEW_CONTESTS_URL: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def four_days_left_to_submit_concept_board(contest, email_id = nil)
    template 'four_days_left_to_submit_concept_board'
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        CONTEST_NAME: contest.name,
        NEW_CONTESTS_URL: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def contest_not_live_yet(contest, email_id = nil)
    template 'Contest-not-live-yet'
    set_template_values(
        ENTRIES_URL: renderer.client_center_entries_url,
        PICTURES_EMAIL: 'pictures@interiorcrowd.com'
    )
    client = contest.client
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def designer_asks_client_a_question_submission_phase(options, email_id = nil)
    template 'Designer-asks-client-a-question-submission-phase'
    set_template_values(
        ENTRY_URL: renderer.client_center_entry_url(id: options[:contest_request].id),
        COMMENT_TEXT: options[:comment_text]
    )
    client = options[:client]
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def account_creation(client, email_id = nil)
    template 'account_creation'
    set_template_values(
        TWITTER_URL: Settings.external_urls.social.twitter,
        TWITTER_ICON_URL: asset_url('/icons/twitter.png'),
        FACEBOOK_URL: Settings.external_urls.social.facebook,
        FACEBOOK_ICON_URL: asset_url('/icons/facebook.png'),
        PINTEREST_URL: Settings.external_urls.social.pinterest,
        PINTEREST_ICON_URL: asset_url('/icons/pinterest.png'),
        INSTAGRAM_URL: Settings.external_urls.social.instagram,
        INSTAGRAM_ICON_URL: asset_url('/icons/instagram.png'),
        PARAGRAPH_1_BACKGROUND_URL: asset_url('/emails/entertain_background.jpg'),
        LOGO_URL: asset_url('/logo.png'),
        FINISH_URL: renderer.design_brief_contests_url,
        TERMS_OF_SERVICE_URL: renderer.terms_of_service_url,
        PRIVACY_POLICY_URL: renderer.privacy_policy_url,
        UNSUBSCRIBE_URL: renderer.unsubscribe_clients_url(signature: client.access_token),
        PROMOCODE_BACKGROUND_URL: asset_url('/emails/back.png')
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  private

  def asset_url(asset_path)
    Settings.app_host + '/assets' + asset_path
  end

  def set_user_params(user)
    {
      name: user.name,
      email: user.email,
      phone: user.phone_number || ''
    }
  end

  def set_invitation_params(client)
    @client_name = client.name
    @days = ContestMilestone::DAYS['submission']
    {
      text: render_to_string('mails/invite_to_contest')
    }
  end

  def set_reset_password_params(user, password)
    {
      name: user.name,
      email: user.email,
      password: password,
      text: I18n.t('reset_password_text')
    }
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
    I18n.t('registration.mail_to')
  end

  def renderer
    @renderer ||= RenderingHelper.new
  end

end