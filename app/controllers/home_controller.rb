class HomeController < ApplicationController

  attr_accessor :incoming_url

  def index
    session[:return_to] = nil
    session[:login_after] = nil
    render
  end

  def sign_up_beta
    render layout: 'sign_up'
  end

  def sign_in_beta
    @incoming_url = params[:url]

    if beta_access_granted?
      unless params[:url].nil?
        return redirect_to params[:url]
      else
        return redirect_to root_path
      end
    end

    render layout: 'sign_up'
  end

  def create_beta_session
    if beta_authentication(params[:password].strip)
      cookies.permanent.signed[:beta] = true
    else
      flash[:error] = "Wrong password"
    end

    if params[:incoming_url].nil?
      redirect_to root_path
    else
      redirect_to params[:incoming_url]
    end
  end

  private

  def beta_authentication(password)
    password == ENV['BETA_PASSWORD']
  end
end
