module User
  extend ActiveSupport::Concern

  include UserPolicies

  included do
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
end
