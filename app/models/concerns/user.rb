module User
  extend ActiveSupport::Concern

  include UserPolicies

  included do
    def self.encrypt(text)
      Digest::SHA1.hexdigest("#{text}")
    end

    def self.authenticate(username, password)
      encrypted_password = encrypt(password)
      username.present? && encrypted_password.present? ?
          self.find_by_email_and_password(username.downcase, encrypted_password) : nil
    end

    def self.find_by_access_token(signature)
      id = verifier.verify(signature)
      find(id)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end

    def self.verifier
      ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
    end

    def self.create_access_token(user)
      verifier.generate(user.id)
    end
  end

  def downcase_email
    self.email = self.email.downcase if self.email
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

  def valid_password?(passed_password)
    self.class.encrypt(passed_password) == self.password
  end

  def set_password(new_plain_password)
    self.password = Client.encrypt(new_plain_password)
    self.plain_password = new_plain_password
  end

  def access_token
    self.class.create_access_token(self)
  end

  def can_create_request_for_contest?(contest)
    designer? && contest.response_of(self).blank?
  end

  def owns_email?(email)
    return false if anonymous?
    self.email == email.downcase
  end

  def avatar_url
    return '/assets/profile-img.png' unless designer?
    PortfolioView.new(portfolio).personal_picture_url('/assets/profile-img.png', :medium)
  end

end
