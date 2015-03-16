class Designer < ActiveRecord::Base
  include User
  validates  :email, :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, uniqueness: true

  has_one :portfolio
  has_many :contest_requests
  has_many :user_notifications, foreign_key: :user_id
  has_many :designer_invite_notifications, foreign_key: :user_id
  has_many :invited_contests, class_name: 'Contest', through: :designer_invite_notifications, source: :contest
  has_many :comments, class_name: 'ConceptBoardComment', through: :contest_requests

  def self.encrypt(text)
     Digest::SHA1.hexdigest("#{text}")
  end

  def self.authenticate(username, password)
     password = encrypt(password)
     username.present? && password.present? ? self.find_by_email_and_password(username, password) : nil
  end

  def has_active_requests?
    contest_requests.active.exists?
  end

  def state
    0
  end

  def create_portfolio(portfolio_params)
    portfolio = Portfolio.create!(designer_id: id)
    if portfolio_params.present? && (portfolio_params[:picture_ids].present? ||
        portfolio_params[:example_links].present?
      )
      portfolio.update_pictures(portfolio_params)
      portfolio.update_links(portfolio_params[:example_links])
      save!
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

  def requests_by_status(status)
    return contest_requests.view_on_board unless status
    statuses = ['submitted', 'fulfillment']
    contest_requests.send(status) if statuses.include? status
  end

  def related_contest_comments
    commented_contests_ids = Contest.includes(:notes).where(contest_notes: { designer_id: id }).group('contests.id').pluck(:id)
    contests_participated_ids = Contest.joins(:requests).where(contest_requests: { designer_id: id }).group('contests.id').pluck(:id)
    related_contests_ids = (commented_contests_ids + contests_participated_ids).uniq
    ContestNote.joins(:contest).where('contests.id IN (?) AND (contest_notes.client_id IS NOT NULL)', related_contests_ids).order(created_at: :desc).includes(contest: [:client])
  end

  def related_comments
    (comments.by_client.includes(contest_request: [:contest]) + related_contest_comments).sort_by{ |comment| comment.updated_at }.reverse
  end

  def notifications
    (related_comments + user_notifications.includes(:contest)).sort_by{ |comment| comment.updated_at }.reverse
  end

end
