# == Schema Information
#
# Table name: example_links
#
#  id           :integer          not null, primary key
#  url          :text
#  portfolio_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class ExampleLink < ActiveRecord::Base

  belongs_to :portfolio

end
