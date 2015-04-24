class SessionsController < ApplicationController
  
  def login
    puts 'login = '
    session[:login_after] = nil
    a = session[:return_to]
    session[:return_to] = nil
    puts a
    puts session[:return_to]
    session[:login_after] = a
    puts session[:login_after]
    redirect_to designer_center_index_path if session[:designer_id].present?
    @login_view = LoginView.designer_login
  end
  
  def client_login
    redirect_to client_center_index_path if session[:client_id].present?
    @login_view = LoginView.client_login
  end
  
  def client_authenticate
    client = Client.authenticate(params[:username], params[:password])
    if client.present?
        session[:client_id] = client.id
        redirect_to client_center_index_path
    else
      flash[:error] = 'Incorrect Username or Password!'
      redirect_to client_login_sessions_url
    end   
  end
  
  
  def authenticate
    puts 'authenticate = '

    designer = Designer.authenticate(params[:username], params[:password])
    puts designer.inspect
    if designer.present?
        puts '***'
        puts session[:return_to].inspect
        puts '888'
        session[:designer_id] = designer.id
        puts "LOGIN_AFTER = "
        puts session[:login_after]
        session[:return_to] = nil
        return redirect_to session[:login_after] if session[:login_after]
        redirect_to designer_center_index_path
    else
      flash[:error] = 'Incorrect Username or Password!'
      redirect_to login_sessions_url
    end   
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
  
end
