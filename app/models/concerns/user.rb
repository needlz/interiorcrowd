module User
  extend ActiveSupport::Concern

  include UserPolicies

  included do
    def self.encrypt(text)
      Digest::SHA1.hexdigest("#{text}")
    end

    def self.authenticate(username, password)
      encrypted_password = encrypt(password)
      username.present? && encrypted_password.present? ? self.find_by_email_and_password(username, encrypted_password) : nil
    end
  end

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
    kind_of?(Anonym)
  end

  def beta?
    cookies.signed[:beta]
  end

  def reset_password
    length_of_random_seed = 5
    new_password = SecureRandom.urlsafe_base64(length_of_random_seed)
    self.set_password(new_password)
    self.save!
    Jobs::Mailer.schedule(:reset_password, [self, new_password])
  end

  def valid_password?(passed_password)
    self.class.encrypt(passed_password) == self.password
  end

  def set_password(new_plain_password)
    self.password = Client.encrypt(new_plain_password)
    self.plain_password = new_plain_password
  end

end
