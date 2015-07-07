class ClientPayment < ActiveRecord::Base

  belongs_to :client
  normalize_attributes :last_error

end
