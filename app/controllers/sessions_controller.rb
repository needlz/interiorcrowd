class SessionsController < ApplicationController
  
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
    if client.present?
        session[:client_id] = client.id
        redirect_to client_center_index_path
    else
      flash[:error] = 'Incorrect Username or Password!'
      redirect_to client_login_sessions_url
    end   
  end
  
  
  def authenticate
    designer = Designer.authenticate(params[:username], params[:password])
    if designer.present?
        session[:designer_id] = designer.id
        redirect_to designer_center_index_path(designer)
    else
      flash[:error] = 'Incorrect Username or Password!'
      redirect_to login_sessions_url
    end   
  end
  
  def retry_password
    if request.method == 'POST'
       designer = Designer.find_by_email(params[:email])
       if designer.present?
        new_password = SecureRandom.urlsafe_base64(5)
        designer.password = Client.encrypt(new_password)
        designer.save
        Jobs::Mailer.schedule(:reset_password, [designer, new_password])
        flash[:notice] = "An email has been sent to your registered email address."
        redirect_to login_sessions_path
       
       else
         flash[:error] = "Email does not exist."
         redirect_to retry_password_sessions_path
       end
    end     
  end
  
  def client_retry_password
    if request.method == 'POST'
       client = Client.find_by_email(params[:email])
       if client.present?
        new_password = SecureRandom.urlsafe_base64(5)
        client.password = Client.encrypt(new_password)
        client.save
        Jobs::Mailer.schedule(:reset_password, [client, new_password])
        flash[:notice] = "An email has been sent to your registered email address."
        redirect_to client_login_sessions_path
       else
         flash[:error] = "Email does not exist."
         redirect_to client_retry_password_sessions_path
       end
    end     
  end
  
  
  def logout
    reset_session
    redirect_to root_path
  end
  
end
