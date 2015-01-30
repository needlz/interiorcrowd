class Client < ActiveRecord::Base
  
  ACTIVE_STATUS = 1
  INACTIVE_STATUS = 0
  
  validates  :email, :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, uniqueness: true
  
  has_many :contests
  belongs_to :designer_level
  has_many :designer_invitations, through: :contests
  
  def self.encrypt(text)
     Digest::SHA1.hexdigest("#{text}")
  end

  def name
    "#{ first_name } #{ last_name }"
  end
  
  def self.authenticate(username, password)
     password = encrypt(password)
     username.present? && password.present? ? self.find_by_email_and_password(username, password) : nil
  end

  def phone_number
    '415-333-3333'
  end

  def last_contest
    contests.order(:created_at).last
  end
end
