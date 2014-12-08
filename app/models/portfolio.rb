class Portfolio < ActiveRecord::Base

  DEGREES = {
      ASSOCIATES: 'associates',
      BACHELORS: 'bachelors',
      MASTERS: 'master',
      DOCTORATE: 'doctorate'
  }

  validates_uniqueness_of :designer_id
  validates_inclusion_of :degree, in: DEGREES.values, allow_nil: true

  has_many :pictures, ->{ portfolio_pictures }, class_name: 'Image'
  has_one :personal_picture, ->{ portfolio_personal_picture }, class_name: 'Image'
  has_one :background_picture, ->{ portfolio_background }, class_name: 'Image'
  belongs_to :designer

  def complete?
    path.present?
  end
end
