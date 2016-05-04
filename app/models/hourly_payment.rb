class HourlyPayment < ActiveRecord::Base
  belongs_to :time_tracker
  belongs_to :client
  belongs_to :credit_card

  normalize_attributes :last_error

end
