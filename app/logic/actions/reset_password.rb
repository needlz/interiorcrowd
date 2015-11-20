class ResetPassword

  def initialize(user)
    @user = user
  end

  def perform
    length_of_random_seed = 5
    new_password = SecureRandom.urlsafe_base64(length_of_random_seed)
    user.set_password(new_password)
    user.save!
    Jobs::Mailer.schedule(:reset_password, [user.id, user.role, new_password])
  end

  private

  attr_reader :user

end
