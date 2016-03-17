class Authenticator

  def self.sign_in(user, session)
    if user.client?
      session[:client_id] = user.id
    elsif user.designer?
      session[:designer_id] = user.id
    end
  end

end
