class Designer < ActiveRecord::Base
  validates  :email, :first_name, :last_name, :presence => true
  validates :password, :on => :create, :presence => true
  validates_confirmation_of :password, :on => :create
  validates :email, :uniqueness => true
  
  def self.encrypt(text)
     Digest::SHA1.hexdigest("#{text}")
  end
end
