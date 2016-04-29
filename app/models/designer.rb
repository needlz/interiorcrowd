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
#  active                  :boolean          default(TRUE)
#  facebook_user_id        :integer
#  last_log_in_at          :datetime
#  last_log_in_ip          :string
#

class Designer < ActiveRecord::Base
  include User
  validates :email, :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, uniqueness: true, email: true
  normalize_attributes :email, :first_name, :last_name, :email, :zip, :state, :phone_number, :address, :city

  has_one :portfolio
  has_many :contest_requests
  has_many :user_notifications, foreign_key: :user_id
  has_many :designer_invite_notifications, foreign_key: :user_id
  has_many :invited_contests, class_name: 'Contest', through: :designer_invite_notifications, source: :contest
  has_many :comments, class_name: 'ConceptBoardComment', through: :contest_requests

  before_save :downcase_email

  scope :active, -> { where(active: true) }

  def first_name
    read_attribute(:first_name).try(:titleize)
  end

  def last_name
    read_attribute(:last_name).try(:titleize)
  end

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
    portfolio.path if portfolio
  end

  ransacker :by_submission_date, formatter: proc { |month|
    date = ActiveAdminExtensions::ContestDetails.ranges_for_month(month)
    designers = Designer.joins(:contest_requests).where(contest_requests: { submitted_at: date..date.next_month }).map(&:id)
    designers.present? ? designers : nil
  } do |parent|
    parent.table[:id]
  end

  ransacker :by_win_date, formatter: proc { |month|
    date = ActiveAdminExtensions::ContestDetails.ranges_for_month(month)
    designers = Designer.joins(:contest_requests).where(contest_requests: { won_at: date..date.next_month }).map(&:id)
    designers.present? ? designers : nil
  } do |parent|
    parent.table[:id]
  end

  ransacker :by_completion_date, formatter: proc { |month|
    date = ActiveAdminExtensions::ContestDetails.ranges_for_month(month)
    designers = Designer.joins(contest_requests: [:contest]).
        where("contest_requests.answer = 'winner'").
        where("contest_requests.status = 'finished'").
        where(contests: { finished_at: date..date.next_month }).map(&:id)
    designers.present? ? designers : nil
  } do |parent|
    parent.table[:id]
  end

end
