class SessionsController < ApplicationController
  
  def login
    redirect_to users_url unless session[:designer_id].nil?
  end
  
  def client_login
    redirect_to users_url unless session[:designer_id].nil?
  end
  
  def client_authenticate
    cinfo = Client.authenticate(params[:username], params[:password])
    if cinfo.present?
        session[:client_id] = cinfo.id 
        redirect_to client_center_clients_path
    else
      flash[:error] = 'Incorrect Username or Password!'
      redirect_to client_login_sessions_url
    end   
  end
  
  
  def authenticate
    dinfo = Designer.authenticate(params[:username], params[:password])
    if dinfo.present?
        session[:designer_id] = dinfo.id 
        redirect_to welcome_designer_path(dinfo)
    else
      flash[:error] = 'Incorrect Username or Password!'
      redirect_to login_sessions_url
    end   
  end
  
  def retry_password
    if request.method == 'POST'
       designer_info = Designer.find_by_email(params[:email])
       if designer_info.present?
        new_password = SecureRandom.urlsafe_base64(5)
        designer_info.password = Client.encrypt(new_password)
        designer_info.save
        ICrowd.reset_password_mail(designer_info, new_password).deliver
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
       client_info = Client.find_by_email(params[:email])
       if client_info.present?
        new_password = SecureRandom.urlsafe_base64(5)
        client_info.password = Client.encrypt(new_password)
        client_info.save
        ICrowd.reset_password_mail(designer_info, new_password).deliver
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
