class Client < ActiveRecord::Base
  include User

  ACTIVE_STATUS = 1
  INACTIVE_STATUS = 0
  
  validates :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, presence: true, uniqueness: true
  normalize_attributes :email

  has_many :contests
  belongs_to :designer_level
  has_many :designer_invite_notifications, through: :contests
  
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

  def last_four_card_digits
    return unless card_number
    card_number if card_number.length < 4
    four_digits = card_number[-4..-1]
    four_digits.presence || card_number
  end

  def can_comment_contest_request?(contest_request)
    contest_request.contest_owner?(self)
  end

  def can_download_concept_board?(contest_request)
    contest_request.contest_owner?(self)
  end

  def can_comment_contest?(contest)
    contest.client == self
  end

end
