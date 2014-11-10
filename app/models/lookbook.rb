class Lookbook < ActiveRecord::Base
  has_many :lookbook_details
  belongs_to :image, foreign_key: :document_id
end
