class ConceptBoardCommentReceivedEmail

  INBOUND_DOMAIN = 'inbound.interiorcrowd.com'

  attr_reader :message

  def self.response_address(contest_request_id)
    "concept-board-#{ contest_request_id }@#{ INBOUND_DOMAIN }"
  end

  def initialize(email)
    @email = email
    @message = Hashie::Mash.new(@email).msg
  end

  def contest_request_id
    return @contest_request_id if @contest_request_id
    reply_address = email['msg']['to'].find{ |to| extract_contest_request_id(to[0]) }
    @contest_request_id = extract_contest_request_id(reply_address[0]) if reply_address
  end

  def comment_text
    Griddler::EmailParser.extract_reply_body(email['msg']['text'])
  end

  def sender_email
    email['msg']['from_email']
  end

  def recipients
    email['msg']['to'].select{ |to| !extract_contest_request_id(to[0]) }
  end

  def response_address
    ConceptBoardCommentReceivedEmail.response_address(contest_request_id)
  end

  def message_id
    message.headers['Message-Id']
  end

  private

  attr_reader :email

  def contest_request
    ContestRequest.find(contest_request_id)
  end

  def extract_contest_request_id(address)
    matches = address.match Regexp.new("concept-board-(\\d+)@#{ Regexp.escape(INBOUND_DOMAIN) }")
    matches[1].to_i if matches
  end

end
