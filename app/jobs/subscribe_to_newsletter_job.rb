class SubscribeToNewsletterJob < ActiveJob::Base
  include Rollbar::ActiveJob
  queue_as Jobs::MAILER_QUEUE

  def perform(user_role, user_id)
    user = user_role.constantize.find(user_id)
    AddEmailToNewsletter.perform(user)
  end
end
