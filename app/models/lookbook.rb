# == Schema Information
#
# Table name: lookbooks
#
#  id         :integer          not null, primary key
#  contest_id :integer
#  feedback   :text
#  created_at :datetime
#  updated_at :datetime
#

class Lookbook < ActiveRecord::Base
  has_many :lookbook_details
  belongs_to :image, foreign_key: :document_id
  has_one :contest_request
end
