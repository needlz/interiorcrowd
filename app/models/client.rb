# == Schema Information
#
# Table name: clients
#
#  id                 :integer          not null, primary key
#  first_name         :text
#  last_name          :text
#  email              :text
#  password           :string(255)
#  name_on_card       :text
#  card_type          :text
#  address            :text
#  state              :text
#  zip                :integer
#  card_number        :text
#  card_ex_month      :integer
#  card_ex_year       :integer
#  card_cvc           :integer
#  status             :integer          default(1)
#  created_at         :datetime
#  updated_at         :datetime
#  designer_level_id  :integer
#  city               :text
#  phone_number       :text
#  billing_address    :text
#  billing_state      :text
#  billing_zip        :integer
#  billing_city       :text
#  plain_password     :string(255)
#  stripe_customer_id :string(255)
#  stripe_card_status :text             default("pending")
#  facebook_user_id   :integer
#  primary_card_id    :integer
#

class Client < ActiveRecord::Base
  include User

  ACTIVE_STATUS = 1
  INACTIVE_STATUS = 0
  
  # validates :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, presence: true, uniqueness: true
  normalize_attributes :email, :stripe_customer_id, :billing_address, :billing_state, :billing_zip, :billing_city

  has_many :contests
  belongs_to :designer_level
  has_many :designer_invite_notifications, through: :contests
  has_many :contest_requests, through: :contests, source: :requests
  has_many :client_payments
  has_many :credit_cards
  belongs_to :primary_card, class_name: 'CreditCard'

  def last_contest
    non_finished_statuses = Contest::NON_FINISHED_STATUSES.map{ |s| "'#{ s }'" }.join(', ')
    contests_order_query = "CASE WHEN contests.status IN (#{ non_finished_statuses }) THEN 2 ELSE CASE WHEN contests.status = \'finished\' THEN 1 ELSE 0 END END DESC"
    contests.order(contests_order_query).order(created_at: :desc).first
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

  def stripe_customer?
    stripe_customer_id
  end

end
