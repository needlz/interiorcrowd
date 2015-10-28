class RieltorContact < ActiveRecord::Base

  CHOICES = [['call me', 'call_me'], ['email me', 'email_me']]

  normalize_attributes :email, :first_name, :last_name, :brokerage, :choice, :phone

  validates :email, presence: true, uniqueness: true

end
