class UserMailer < ActionMailer::Base
  include MandrillMailer
  include Rails.application.routes.url_helpers

  def renderer
    @renderer ||= RenderingHelper.new
  end

  def client_registered(client)
    template 'client_welcome_mail'
    set_template_values(login_link: renderer.client_login_sessions_url,
                        submission_days: ContestMilestone::DAYS['submission'])
    mail to: [wrap_recipient(client.email, client.first_name, 'to')]
  end

  def designer_registered(designer)
    template 'user_registration'
    subject = I18n.t('mails.designer_registration.subject')
    set_template_values(text: render_to_string('mails/designer_registration'))
    mail to: [wrap_recipient(designer.email, designer.first_name, 'to')], subject: subject
  end

  def user_registration_info(user)
    template "#{ user.role.downcase }_registration_info"
    set_template_values(set_user_params(user))
    mail to: [wrap_recipient(Settings.info_email, '', 'to')]
  end

  def invite_to_contest(designer, client)
    template 'invite_to_contest'
    set_template_values(set_invitation_params(client))
    mail to: [wrap_recipient(designer.email, designer.name, 'to')]
  end

  def reset_password(user, password)
    template 'reset_password'
    subject = I18n.t('mails.password_reset.subject')
    set_template_values(set_reset_password_params(user, password))
    mail to: [wrap_recipient(user.email, user.name, 'to')], subject:subject
  end

  def sign_up_beta_autoresponder(email)
    template 'sign_up_beta_autoresponder'
    subject = I18n.t('mails.beta_autorespond.subject')
    mail to: [wrap_recipient(email, '', "to")], subject:subject
  end

  def notify_about_new_subscriber(beta_subscriber)
    return unless Rails.env.production?
    template 'new_beta_subscriber'
    set_template_values(new_subscriber_params(beta_subscriber))
    recipients = Settings.beta_notification_emails.map do |email|
      wrap_recipient(email, 'InteriorCrowd', 'to')
    end
    mail to: recipients, subject: I18n.t('mails.beta_subscriber.subject')
  end

  def product_list_feedback(params, contest_request_id)
    template 'product_list_feedback'
    @url = edit_designer_center_response_url(contest_request_id)
    set_template_values(text: render_to_string('mails/product_list_feedback'))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t('mails.product_list_feedback.subject')
  end

  def invitation_to_leave_a_feedback(params, url, client, beta_url)
    template 'invitation_to_leave_a_feedback'
    @client_name = client.name
    @page_url = url
    @beta_url = beta_url
    set_template_values(text: render_to_string('mails/invite_to_leave_feedback'))
    mail to: [wrap_recipient(params['email'], params['username'], 'to')],
         subject: I18n.t('mails.invitation_to_leave_feedback.subject', client_name: @client_name)
  end

  def concept_board_received(contest_request)
    client = contest_request.contest.client
    email = client.email
    username = client.name
    template 'generic_notification'
    set_template_values(text: render_to_string('mails/new_concept_board_received'))
    mail to: [wrap_recipient(email, username, 'to')],
         subject: I18n.t('mails.concept_board_received.subject')
  end

  def comment_on_board(params, contest_request_id)
    template 'comment_on_board'
    @url = url_for_comment_on_board(params[:role], contest_request_id)
    @author_name = params[:username]
    @comment = ERB::Util.html_escape(params[:comment]).split("\n").join("<br/>")
    set_template_values(text: render_to_string("mails/#{params[:role]}s_comment_on_board"))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t("mails.#{params[:role]}s_comment_on_board.subject")
  end


  def note_to_concept_board(params)
    template 'note_to_concept_board'
    @url = designer_center_updates_url
    @client_name = params[:client_name]
    @comment = ERB::Util.html_escape(params[:comment]).split("\n").join("<br/>")
    set_template_values(text: render_to_string('mails/note_to_concept_board'))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t('mails.note_to_concept_board.subject')
  end

  def new_product_list_item(params)
    template "new_product_list_item"
    @url = entries_client_center_index_url
    set_template_values(text: render_to_string("mails/new_product_list_item"))
    mail to: [wrap_recipient(params[:email], params[:username], 'to')],
         subject: I18n.t("mails.new_product_list_item.subject")
  end

  def notify_designer_about_win(contest_request)
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
    mail to: [wrap_recipient(designer.email, designer.name, 'to')]
  end

  def please_pick_winner(contest)
    template 'client_must_pick_a_winner'
    client = contest.client
    set_template_values(
        DAYS_TO_PICK_WINNER: ContestMilestone::DAYS['winner_selection'],
        ENTRIES_URL: renderer.entries_client_center_index_url,
        CLIENT_FAQ_URL: renderer.faq_url(anchor: 'client'),
        HELLO_ADDRESS: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')])
  end

  def remind_about_picking_winner(contest)
    template 'client_hasnt_picked_a_winner'
    client = contest.client
    set_template_values(
        ENTRIES_URL: renderer.entries_client_center_index_url,
        HELLO_ADDRESS: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')])
  end

  def client_has_picked_a_winner(contest_request)
    template 'client_has_picked_a_winner'
    client = contest_request.contest.client
    set_template_values(
        HELLO_ADDRESS: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')])
  end

  def client_ready_for_final_design(contest_request)
    template 'client_ready_for_final_design'
    client = contest_request.contest.client
    designer = contest_request.designer
    set_template_values(
        CLIENT_NAME: client.name
    )
    mail(to: [wrap_recipient(designer.email, designer.name, 'to')])
  end

  def client_hasnt_picked_a_winner_to_designers(contest)
    template 'client_ready_for_final_design'
    designers = Designer.joins(:contest_requests).where(contest_requests: { id: contest.requests.submitted.pluck(:id) })
    set_template_values(
        CONTEST_NAME: contest.name
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') })
  end

  def designer_submitted_final_design(contest_request)
    template 'Designer_submitted_final_design'
    client = contest_request.contest.client
    set_template_values(
        HELLO_ADDRESS: contact_email
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')])
  end

  def no_concept_boards_received_after_three_days(contest)
    template 'No_concept_boards_received_after_three_days'
    client = contest.client
    mail(to: [wrap_recipient(client.email, client.name, 'to'), wrap_recipient(contact_email, 'InteriorCrowd', 'to')])
  end

  def one_day_left_to_choose_a_winner(contest)
    template 'One_day_left_to_choose_a_winner'
    client = contest.client
    set_template_values(
        HELLO_ADDRESS: contact_email,
        CLIENT_NAME: client.name,
        ENTRIES_URL: renderer.entries_client_center_index_url,
        CLIENT_FAQ_URL: renderer.faq_url(anchor: 'client')
    )
    mail(to: [wrap_recipient(client.email, client.name, 'to')])
  end

  def one_day_left_to_submit_concept_board(contest)
    template 'One_day_left_to_submit_concept_board'
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        CONTEST_NAME: contest.name,
        NEW_CONTESTS_URL: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') })
  end

  def four_days_left_to_submit_concept_board(contest)
    template 'four_days_left_to_submit_concept_board'
    designers = SubscribedDesignersQueryNotSubmitted.new(contest).designers
    set_template_values(
        CONTEST_NAME: contest.name,
        NEW_CONTESTS_URL: renderer.designer_center_contest_index_url
    )
    mail(to: designers.map{ |designer| wrap_recipient(designer.email, designer.name, 'to') })
  end

  private

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
    entries_client_center_index_url
  end

  def contact_email
    I18n.t('registration.mail_to')
  end

end