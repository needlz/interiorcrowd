class RieltorContact < ActiveRecord::Base

  CHOICES = {call: 'call_me', email: 'email_me'}

  normalize_attributes :email, :first_name, :last_name, :brokerage, :choice, :phone

  validates :email, presence: true, uniqueness: true, email: true, if: :email_me?
  validates :phone, presence: true, numericality: true, length: { is: 10 }, uniqueness: true, if: :call_me?
  validates_inclusion_of :choice, in: CHOICES.values

  def call_me?
    choice == CHOICES[:call]
  end

  def email_me?
    choice == CHOICES[:email]
  end

end
