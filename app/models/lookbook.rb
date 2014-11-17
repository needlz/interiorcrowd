class Lookbook < ActiveRecord::Base
  has_many :lookbook_details
  belongs_to :image, foreign_key: :document_id
  has_one :contest_request
end
