class Anonym
  include User

  def role
    'Anonym'
  end

  def can_comment_contest_request?(contest_request)
    false
  end

end
