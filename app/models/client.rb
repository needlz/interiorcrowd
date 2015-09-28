# == Schema Information
#
# Table name: clients
#
#  id                 :integer          not null, primary key
#  first_name         :text
#  last_name          :text
#  email              :text
#  password           :string(255)
#  address            :text
#  state              :text
#  zip                :integer
#  status             :integer          default(1)
#  created_at         :datetime
#  updated_at         :datetime
#  designer_level_id  :integer
#  city               :text
#  phone_number       :text
#  plain_password     :string(255)
#  stripe_customer_id :string(255)
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
  normalize_attributes :email, :stripe_customer_id

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
