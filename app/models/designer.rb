# == Schema Information
#
# Table name: designers
#
#  id                      :integer          not null, primary key
#  first_name              :text
#  last_name               :text
#  email                   :text
#  password                :string(255)
#  zip                     :text
#  ex_links                :text
#  ex_document_ids         :text
#  created_at              :datetime
#  updated_at              :datetime
#  portfolio_background_id :integer
#  portfolio_path          :text
#  phone_number            :text
#  plain_password          :text
#  state                   :string(255)
#  address                 :text
#  city                    :text
#  linkedin_profile        :string(255)
#  active                  :boolean          default(TRUE)
#  facebook_user_id        :integer
#

class Designer < ActiveRecord::Base
  include User
  validates  :email, :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, uniqueness: true
  normalize_attributes :email, :first_name, :last_name, :email, :zip, :state, :phone_number, :address, :city

  has_one :portfolio
  has_many :contest_requests
  has_many :user_notifications, foreign_key: :user_id
  has_many :designer_invite_notifications, foreign_key: :user_id
  has_many :invited_contests, class_name: 'Contest', through: :designer_invite_notifications, source: :contest
  has_many :comments, class_name: 'ConceptBoardComment', through: :contest_requests

  scope :active, -> { where(active: true) }

  def has_active_requests?
    contest_requests.active.exists?
  end

  def create_portfolio(portfolio_params)
    ActiveRecord::Base.transaction do
      portfolio_creation = PortfolioCreation.new(designer_id: id,
                                                 portfolio_options: portfolio_params)
      portfolio_creation.perform
    end
  end

  def invited_to_contest?(contest)
    designer_invite_notifications.exists?(contest_id: contest.id)
  end

  def can_comment_contest_request?(contest_request)
    contest_request.designer == self
  end

  def can_download_concept_board?(contest_request)
    contest_request.designer == self
  end

  def can_comment_contest?(contest)
    true
  end

  def requests_by_status(statuses)
    return contest_requests.active unless statuses
    contest_requests.where(status: statuses)
  end

  def notifications
    user_notifications.includes(:contest, :contest_comment, :concept_board_comment).order(created_at: :desc)
  end

  def portfolio_path
    portfolio.try(:path)
  end

end
