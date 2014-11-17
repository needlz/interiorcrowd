class Client < ActiveRecord::Base
  
  ACTIVE_STATUS = 1
  INACTIVE_STATUS = 0
  
  validates  :email, :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, uniqueness: true
  
  has_many :contests
  belongs_to :designer_level
  
  def self.encrypt(text)
     Digest::SHA1.hexdigest("#{text}")
  end
  
  def self.authenticate(username, password)
     password = encrypt(password)
     username.present? && password.present? ? self.find_by_email_and_password(username, password) : nil
  end

  def last_contest
    contests.order(:created_at).last
  end
end
