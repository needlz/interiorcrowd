class ReviewerInvitation < ActiveRecord::Base

  before_validation :strip_whitespace

  validates_presence_of :username, :email
  validates_format_of :email, :with => /@/

  after_initialize :generate_url, if: :new_record?

  belongs_to :contest
  has_many :feedbacks, class_name: 'ReviewerFeedback', foreign_key: 'invitation_id'

  private

  def strip_whitespace
    self.username = self.username.strip
    self.email = self.email.strip
  end

  def generate_url
    self.url = TokenGenerator.generate
  end

end
