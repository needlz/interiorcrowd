class BetaSubscriber < ActiveRecord::Base

  validates_inclusion_of :role, in: %w(designer consumer), allow_nil: true
  validates_uniqueness_of :email
  validates_format_of :email, :with => /@/

end
