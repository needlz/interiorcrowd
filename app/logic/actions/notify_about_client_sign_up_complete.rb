class NotifyAboutClientSignUpComplete

  def initialize(client)
    @client = client
  end

  def perform
    return if client.notified_owner
    Jobs::Mailer.schedule(:user_registration_info, [client.role, client.id])
    client.update_attributes!(notified_owner: true)
  end

  private

  attr_reader :client

end
