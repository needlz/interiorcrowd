# == Schema Information
#
# Table name: beta_subscribers
#
#  id         :integer          not null, primary key
#  email      :text
#  role       :string(255)
#  name       :text
#  created_at :datetime
#  updated_at :datetime
#

class BetaSubscriber < ActiveRecord::Base

  validates_inclusion_of :role, in: %w(designer consumer), allow_nil: true
  validates_uniqueness_of :email
  validates_format_of :email, :with => /@/

end
