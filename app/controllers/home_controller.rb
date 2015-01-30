class HomeController < ApplicationController
  def index
    render
  end

  def sign_up_beta
    render layout: 'sign_up'
  end
end
