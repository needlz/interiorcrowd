# == Schema Information
#
# Table name: clients
#
#  id                :integer          not null, primary key
#  first_name        :text
#  last_name         :text
#  email             :text
#  password          :string(255)
#  name_on_card      :text
#  card_type         :text
#  address           :text
#  state             :text
#  zip               :integer
#  card_number       :text
#  card_ex_month     :integer
#  card_ex_year      :integer
#  card_cvc          :integer
#  status            :integer          default(1)
#  created_at        :datetime
#  updated_at        :datetime
#  designer_level_id :integer
#  city              :text
#  phone_number      :text
#  billing_address   :text
#  billing_state     :text
#  billing_zip       :integer
#  billing_city      :text
#  plain_password    :string(255)
#

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
