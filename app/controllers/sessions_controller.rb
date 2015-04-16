class SessionsController < ApplicationController

  before_filter :set_link_after_login, only: [:login, :client_login]

  def login
    redirect_to designer_center_index_path if session[:designer_id].present?
    @login_view = LoginView.designer_login
  end
  
  def client_login
    redirect_to client_center_index_path if session[:client_id].present?
    @login_view = LoginView.client_login
  end
  
  def client_authenticate
    client = Client.authenticate(params[:username], params[:password])
    authenticate_user(client, client_login_sessions_url)
  end
  
  def authenticate
    designer = Designer.authenticate(params[:username], params[:password])
    authenticate_user(designer, login_sessions_url)
  end
  
  def retry_password
    if request.method == 'POST'
       designer = Designer.find_by_email(params[:email])
       if designer.present?
         designer.reset_password
         flash[:notice] = t('reset_password.email_send')
         redirect_to login_sessions_path
       else
         flash[:error] = t('reset_password.email_does_not_exist')
         redirect_to retry_password_sessions_path
       end
    end     
  end
  
  def client_retry_password
    if request.method == 'POST'
       client = Client.find_by_email(params[:email])
       if client.present?
         client.reset_password
         flash[:notice] = t('reset_password.email_send')
         redirect_to client_login_sessions_path
       else
         flash[:error] = t('reset_password.email_does_not_exist')
         redirect_to client_retry_password_sessions_path
       end
    end     
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
      session["#{user.class.name.downcase}_id".to_sym] = user.id
      track_login
      return redirect_to session[:login_after] if session[:login_after]
      redirect_to send("#{user.class.name.downcase}_login_sessions_path")
    else
      flash[:error] = 'Incorrect Username or Password!'
      session[:return_to] = session[:login_after]
      redirect_to url
    end
  end
  
  def track_login
    tracker = EventTracker.new
    tracker.user = current_user
    tracker.login
  end

end
