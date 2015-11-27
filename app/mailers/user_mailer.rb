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
    mail to: [wrap_recipient(contact_email, '', 'to')], email_id: email_id
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
    mail({to: [wrap_recipient(user.email, user.name, 'to')], subject:subject, email_id: email_id})
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

  def invitation_to_leave_a_feedback(params, url, client_name, root_url, email_id = nil)
    template 'invitation_to_leave_a_feedback'
    @client_name = client_name
    @page_url = url
    @root_url = root_url
    set_template_values(text: render_to_string('mails/invite_to_leave_feedback'))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
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
        hello_address: contact_email,
        contest_url: renderer.designer_center_contest_url(id: contest.id),
        contest_name: contest.name,
        client_name: client.name
    )
    mail to: [wrap_recipient(designer.email, designer.name, 'to')], email_id: email_id
  end

  def please_pick_winner(contest, email_id = nil)
    template 'client_must_pick_a_winner'
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
    template 'client_hasnt_picked_a_winner'
    client = contest.client
    set_template_values(
        entries_url: renderer.client_center_entries_url,
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def client_has_picked_a_winner(contest_request, email_id = nil)
    template 'client_has_picked_a_winner'
    client = contest_request.contest.client
    set_template_values(
        hello_address: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def client_ready_for_final_design(contest_request, email_id = nil)
    template 'client_ready_for_final_design'
    client = contest_request.contest.client
    designer = contest_request.designer
    set_template_values(
        client_name: client.name
    )
    mail(to: [wrap_recipient(designer.email, designer.name, 'to')], email_id: email_id)
  end

  def client_hasnt_picked_a_winner_to_designers(contest, email_id = nil)
    template 'client_hasnt_picked_a_winner_to_designers'
    designers = Designer.joins(:contest_requests).where(contest_requests: { id: contest.requests.submitted.pluck(:id) })
    set_template_values(
        contest_name: contest.name
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def designer_submitted_final_design(contest_request, email_id = nil)
    template 'Designer_submitted_final_design'
    client = contest_request.contest.client
    set_template_values(
        hello_address: contact_email
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
        hello_address: contact_email,
        client_name: client.name,
        entries_url: renderer.client_center_entries_url,
        client_faq_url: renderer.faq_url(anchor: 'client')
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def one_day_left_to_submit_concept_board(contest, email_id = nil)
    template 'One_day_left_to_submit_concept_board'
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        contest_name: contest.name,
        new_contests_url: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def four_days_left_to_submit_concept_board(contest, email_id = nil)
    template 'four_days_left_to_submit_concept_board'
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        contest_name: contest.name,
        new_contests_url: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') }, email_id: email_id)
  end

  def contest_not_live_yet(contest, email_id = nil)
    template 'Contest-not-live-yet'
    set_template_values(
        entries_url: renderer.client_center_entries_url,
        pictures_email: 'pictures@interiorcrowd.com'
    )
    client = contest.client
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def designer_asks_client_a_question_submission_phase(options, email_id = nil)
    template 'Designer-asks-client-a-question-submission-phase'
    set_template_values(
        entry_url: renderer.client_center_entry_url(id: options[:contest_request].id),
        comment_text: options[:comment_text]
    )
    client = options[:client]
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def account_creation(client, email_id = nil)
    template 'account_creation'
    set_template_values(
        twitter_url: Settings.external_urls.social.twitter,
        twitter_icon_url: asset_url('/icons/twitter.png'),
        facebook_url: Settings.external_urls.social.facebook,
        facebook_icon_url: asset_url('/icons/facebook.png'),
        pinterest_url: Settings.external_urls.social.pinterest,
        pinterest_icon_url: asset_url('/icons/pinterest.png'),
        instagram_url: Settings.external_urls.social.instagram,
        instagram_icon_url: asset_url('/icons/instagram.png'),
        paragraph_1_background_url: asset_url('/emails/entertain_background.jpg'),
        logo_url: asset_url('/logo.png'),
        finish_url: renderer.design_brief_contests_url,
        terms_of_service_url: renderer.terms_of_service_url,
        privacy_policy_url: renderer.privacy_policy_url,
        unsubscribe_url: renderer.unsubscribe_clients_url(signature: client.access_token),
        promocode_background_url: asset_url('/emails/back.png')
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')], email_id: email_id)
  end

  def new_project_on_the_platform(client_name, project_name, designers, email_id = nil)
    template 'New-project-on-the-platform'
    set_template_values(
        client_name: client_name,
        project_name: project_name,
        login_url: designer_login_sessions_url
    )
    recipients = designers.map do |designer|
      wrap_recipient(designer.email, designer.name, 'to')
    end
    mail to: recipients, email_id: email_id
  end

  def to_designers_one_submission_only(contest, email_id = nil)
    template 'to_designers_one_submission_only'
    mail_about_contest_submissions(contest, email_id)
  end

  def to_designers_client_no_submissions(contest, email_id = nil)
    template 'To_designers_Client_no_submissions'
    mail_about_contest_submissions(contest, email_id)
  end

  def client_moved_to_final_design(contest_id, email_id = nil)
    template 'client-ready-for-final-design-1'
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
    Settings.info_email
  end

  def renderer
    @renderer ||= RenderingHelper.new
  end

  def mail_about_contest_submissions(contest, email_id)
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

end
