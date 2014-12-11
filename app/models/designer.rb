class Designer < ActiveRecord::Base
  validates  :email, :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, uniqueness: true

  has_one :portfolio

  def self.encrypt(text)
     Digest::SHA1.hexdigest("#{text}")
  end
  
  def self.authenticate(username, password)
     password = encrypt(password)
     username.present? && password.present? ? self.find_by_email_and_password(username, password) : nil
  end

  def name
    "#{ first_name } #{ last_name }"
  end
end
