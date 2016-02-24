class MandrillInboundEmailProcessor
  include MandrillMailer

  attr_reader :comment

  def initialize(email_json, email)
    @email_json = email_json
    @email = email
  end

  def process
    @inbound_email = save_email
    @parser = ConceptBoardCommentReceivedEmail.new(email)
    @contest_request_id = parser.contest_request_id
    process_concept_board_comment if contest_request_id
  end

  def recipient
    comment_notifier = CommentNotifier.new(contest_request, author, comment_text)
    comment_notifier.recipient
  end

  private

  attr_reader :email, :parser, :contest_request_id, :contest_request, :author, :inbound_email, :comment_text

  def process_concept_board_comment
    begin
      @contest_request = ContestRequest.find_by_id(contest_request_id)
      @author = contest_request_participant(contest_request, parser.sender_email)
      raise("Unknown concept board participant: #{ parser.sender_email }") unless author

    rescue StandardError => e
      ErrorsLogger.log(e)
    end

    @comment_text = parser.comment_text
    ActiveRecord::Base.transaction do
      create_comment
      forward_email
      @inbound_email.update_attributes!(processed: true)
    end
  end

  def create_comment
    comment_creation = ConceptBoardCommentCreation.new(@contest_request, { text: comment_text }, @author)
    @comment = comment_creation.perform
  end

  def mandrill_message
    email_view = ConceptBoardCommentEmail.new(@comment)
    {
      to: parser.recipients + [{ email: recipient.email, name: recipient.name, type: 'to' }],
      html: email_html,
      from_email: 'notifier@interiorcrowd.com',
      from_name: 'Interiorcrowd',
      subject: email_view.subject,
      headers: email_view.headers,
      metadata: {
          inbound_email_id: inbound_email.id,
          environment: Rails.env
      },
      auto_text: true
    }
  end

  def forward_email
    api.messages.send(mandrill_message)
  end

  def contest_request_participant(contest_request, email)
    return unless contest_request
    return contest_request.contest.client if contest_request.contest.client.owns_email?(email.downcase)
    contest_request.designer if contest_request.designer.owns_email?(email.downcase)
  end

  def save_email
    InboundEmail.create!(json_content: @email_json)
  end

  def email_html
    result = "<div style=\"color:#777;margin:3px 0\">#{ Griddler.configuration.reply_delimiter }</div><hr style=\"margin:0;border:0;border-top:2px solid #ccc\">"
    result + (parser.message.html || parser.message.text)
  end

end
