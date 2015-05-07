# == Schema Information
#
# Table name: portfolio_awards
#
#  id           :integer          not null, primary key
#  portfolio_id :integer
#  name         :text
#  created_at   :datetime
#  updated_at   :datetime
#

class PortfolioAward < ActiveRecord::Base

  belongs_to :portfolio

end
