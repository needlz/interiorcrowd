class BetaSubscribersController < ApplicationController

  def create
    subscriber = BetaSubscriber.new(subscriber_params)
    if subscriber.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'Error'
    end
    redirect_to root_path
  end

  private

  def subscriber_params
    params.require(:beta_subscriber).permit(:role, :email, :name)
  end

end
