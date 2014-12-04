class Designer < ActiveRecord::Base
  validates  :email, :first_name, :last_name, presence: true
  validates :password, on: :create, presence: true
  validates_confirmation_of :password, on: :create
  validates :email, uniqueness: true
  validate :portfolio_path_provided

  has_many :portfolio_pictures, ->{ portfolio_pictures }, class_name: 'Image'

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

  def has_portfolio?
    portfolio_published
  end

  private

  def portfolio_path_provided
    errors.add(:portfolio_path, 'must be specified in order to publish portfolio') if portfolio_published && portfolio_path.blank?
  end
end
