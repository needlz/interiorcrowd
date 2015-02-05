class BetaSubscribersController < ApplicationController

  def create
    subscriber = BetaSubscriber.new(subscriber_params)
    if subscriber.save
      UserMailer.new.sign_up_beta_autoresponder(subscriber.email)
      UserMailer.new.notify_about_new_subscriber(subscriber)
      flash[:notice] = t('sign_up_beta.success')
    else
      flash[:error] = subscriber.errors.full_messages.join(', ')
    end
    redirect_to root_path
  end

  private

  def subscriber_params
    params.require(:beta_subscriber).permit(:role, :email, :name)
  end

end
