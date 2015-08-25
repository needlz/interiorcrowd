class SessionsController < ApplicationController

  before_filter :set_link_after_login, only: [:designer_login, :client_login]

  def designer_login
    user_login('designer')
  end
  
  def client_login
    user_login('client')
  end

  def client_fb_authenticate
    return return_with_error(client_login_sessions_url, 'OAuth code not provided') unless params[:code]
    session[:access_token] = Koala::Facebook::OAuth.new(client_fb_authenticate_sessions_url).get_access_token(params[:code])
    return return_with_error(client_login_sessions_url, 'No access') unless session[:access_token]
    fb_user = Koala::Facebook::API.new(session[:access_token])
    fb_user_info = fb_user.api('me', { fields: ['id', 'name', 'email', 'first_name', 'last_name' ]})
    client = Client.find_by_facebook_user_id(fb_user_info['id'])
    return return_with_error(client_login_sessions_url, 'Not registered') unless client
    authenticate_user(client, client_login_sessions_url)
  end

  def designer_fb_authenticate
    return return_with_error(designer_login_sessions_url, 'OAuth code not provided') unless params[:code]
    session[:access_token] = Koala::Facebook::OAuth.new(designer_fb_authenticate_sessions_url).get_access_token(params[:code])
    return return_with_error(designer_login_sessions_url, 'No access') unless session[:access_token]
    fb_user = Koala::Facebook::API.new(session[:access_token])
    fb_user_info = fb_user.api('me', { fields: ['id', 'name', 'email', 'first_name', 'last_name' ]})
    designer = Designer.find_by_facebook_user_id(fb_user_info['id'])
    return return_with_error(designer_login_sessions_url, 'Not registered') unless designer
    authenticate_user(designer, designer_login_sessions_url)
  end

  def client_authenticate
    user_authenticate('client')
  end
  
  def authenticate
    user_authenticate('designer')
  end
  
  def designer_retry_password
    user_retry_password('designer')
  end
  
  def client_retry_password
    user_retry_password('client')
  end
  
  def logout
    reset_session
    redirect_to root_path
  end

  private

  def set_link_after_login
    session[:login_after] = session[:return_to]
    session[:return_to] = nil
  end

  def authenticate_user(user, url)
    if user.present?
      session["#{ user.class.name.downcase }_id".to_sym] = user.id
      @current_user = fetch_current_user
      track_login
      return redirect_to session[:login_after] if session[:login_after]
      redirect_to send("#{ user.class.name.downcase }_login_sessions_path")
    else
      session[:return_to] = session[:login_after]
      return_with_error(url, 'Incorrect Username or Password!')
    end
  end
  
  def track_login
    @event_tracker.user = current_user
    @event_tracker.login
  end

  def return_with_error(url, error)
    flash[:error] = error
    redirect_to url
  end

  def user_login(user_role)
    redirect_to send("#{ user_role }_center_path") if session["#{ user_role }_id".to_sym].present?
    @login_view = LoginView.send("#{ user_role }_login")
  end

  def user_authenticate(user_role)
    user_class = user_role.capitalize.constantize
    user = user_class.authenticate(params[:username], params[:password])
    authenticate_user(user, send("#{ user_role }_login_sessions_url"))
  end

  def user_retry_password(user_role)
    if request.method == 'POST'
      user_class = user_role.capitalize.constantize
      user = user_class.find_by_email(params[:email])
      if user.present?
        user.reset_password
        flash[:notice] = t('reset_password.email_send')
      else
        flash[:error] = t('reset_password.email_does_not_exist')
      end
      redirect_to send("#{ user_role }_login_sessions_path")
    end
  end

end
