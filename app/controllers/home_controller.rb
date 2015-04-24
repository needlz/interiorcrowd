class HomeController < ApplicationController
  def index
    session[:return_to] = nil
    session[:login_after] = nil
    render
  end

  def sign_up_beta
    render layout: 'sign_up'
  end

  def sign_in_beta
    puts '______________2'
    return redirect_to root_path if beta_access_granted?
    render layout: 'sign_up'
  end

  def create_beta_session
    if beta_authentication(params[:password].strip)
      cookies.permanent.signed[:beta] = true
    else
      flash[:error] = "Wrong password"
    end
    redirect_to root_path
  end

  private

  def beta_authentication(password)
    password == ENV['BETA_PASSWORD']
  end
end
