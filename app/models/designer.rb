class Designer < ActiveRecord::Base
  validates  :email, :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, uniqueness: true

  has_one :portfolio
  has_many :contest_requests
  has_many :user_notifications, foreign_key: :user_id
  delegate :designer_notifications, to: :user_notifications

  def self.encrypt(text)
     Digest::SHA1.hexdigest("#{text}")
  end
  
  def self.authenticate(username, password)
     password = encrypt(password)
     username.present? && password.present? ? self.find_by_email_and_password(username, password) : nil
  end

  def name
    "#{ first_name } #{ last_name }"
  end

  def has_active_requests?
    contest_requests.active.exists?
  end

  def state
    0
  end

  def create_portfolio(portfolio_params)
    if portfolio_params.present? && (portfolio_params[:picture_ids].present? ||
        portfolio_params[:example_links].present?
      )
      portfolio = Portfolio.create!(designer_id: id)
      portfolio.update_pictures(portfolio_params)
      portfolio.update_links(portfolio_params[:example_links])
      save!
    end
  end

  def invited_to_contest?(contest)
    designer_invitations.exists?(contest_id: contest.id)
  end

end
