module User
  extend ActiveSupport::Concern

  include UserPolicies

  def name
    "#{ first_name } #{ last_name }"
  end

  def role
    self.class.name
  end

  def designer?
    kind_of?(Designer)
  end

  def client?
    kind_of?(Client)
  end

  def anonymous?
    self.class == Object
  end

  def beta?
    cookies.signed[:beta]
  end

  def change_password
    new_password = SecureRandom.urlsafe_base64(5)
    self.password = Client.encrypt(new_password)
    self.plain_password = new_password
    self.save
    Jobs::Mailer.schedule(:reset_password, [self, new_password])
  end

end
