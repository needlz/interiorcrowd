class CreditCard < ActiveRecord::Base

  belongs_to :client

  validates :number, uniqueness: { scope: :client_id }

  validates_length_of  :zip,
                       :is => 5,
                       :message => "should be 5 digits"

end
