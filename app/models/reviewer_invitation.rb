class ReviewerInvitation < ActiveRecord::Base

  before_validation :strip_whitespace

  validates_presence_of :username, :email

  after_initialize :generate_url, if: :new_record?

  belongs_to :contest

  private

  def strip_whitespace
    self.username = self.username.strip
    self.email = self.email.strip
  end

  def generate_url
    self.url = SecureRandom.hex[0, 10]
  end

end
