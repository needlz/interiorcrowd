class ConceptBoardCommentEmail

  def initialize(comment)
    @comment = comment
  end

  def message_id
    "<#{ thread_id }_#{ comment.id }@#{ Settings.app_domain }>"
  end

  def references
    result = []
    parent = comment.parent
    while parent
      result << ConceptBoardCommentEmail.new(parent).message_id
      parent = parent.parent
    end
    result.reverse.join(' ')
  end

  def in_reply_to
    ConceptBoardCommentEmail.new(comment.parent).message_id if comment.parent
  end

  def reply_to
    ConceptBoardCommentReceivedEmail.response_address(comment.contest_request.id)
  end

  def headers
    {
      'Reply-To' => reply_to,
      'In-Reply-To' => in_reply_to,
      'References' => references,
      'Message-Id' => message_id
    }
  end

  def subject
    "Concept board for \"#{ comment.contest_request.contest.name }\""
  end

  private

  attr_reader :comment

  def thread_id
    comment.contest_request.email_thread_id
  end

end
