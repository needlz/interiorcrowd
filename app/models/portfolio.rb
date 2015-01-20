class Portfolio < ActiveRecord::Base

  DEGREES = %w(associate bachelor master doctorate)

  STYLES = %w(modern traditional coastal eclectic midcentury_modern rustic_elegance
              vintage contemporary global hollywood_glam transitional color_pop)

  validates_uniqueness_of :designer_id
  validates_inclusion_of :degree, in: DEGREES, allow_nil: true

  has_many :pictures, ->{ portfolio_pictures }, class_name: 'Image'
  has_one :personal_picture, ->{ portfolio_personal_picture }, class_name: 'Image'
  has_one :background_picture, ->{ portfolio_background }, class_name: 'Image'
  belongs_to :designer

  def complete?
    path.present?
  end

  def update_pictures(portfolio_params)
    portfolio_pictures_ids = portfolio_params[:picture_ids].try(:split, ',').try(:map, &:to_i)
    personal_picture_id = portfolio_params[:personal_picture_id]
    background_picture_id = portfolio_params[:background_picture_id]
    Image.update_portfolio(self, background_picture_id, personal_picture_id, portfolio_pictures_ids)
  end
end
