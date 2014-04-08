class SessionsController < ApplicationController
  
  def login
    redirect_to users_url unless session[:id].nil?
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
     designer_info = Designer.find_by_email(params[:email])
     if udesigner_infoser_info.present?
      new_password = SecureRandom.urlsafe_base64(5)
      designer_info.password = User.encrypt(new_password)  
      designer_info.save
      ICrowd.reset_password_mail(designer_info, new_password).deliver
     else
       flash[:error] = "Email does not exist."
     end
  end
  
  
  def logout
    reset_session
    redirect_to login_sessions_path
  end
  
end
