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

  def can_download_concept_board?(contest_request)
    contest_request.designer == self
  end

end
