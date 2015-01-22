class Portfolio < ActiveRecord::Base

  DEGREES = %w(associate bachelor master doctorate)

  STYLES = %w(modern traditional coastal eclectic midcentury_modern rustic_elegance
              vintage contemporary global hollywood_glam transitional color_pop)

  validates_uniqueness_of :designer_id
  validates_inclusion_of :degree, in: DEGREES, allow_nil: true

  has_many :pictures, ->{ portfolio_pictures }, class_name: 'Image'
  has_one :personal_picture, ->{ portfolio_personal_picture }, class_name: 'Image'
  belongs_to :background, class_name: 'Image'
  belongs_to :designer

  def complete?
    path.present?
  end

  def update_pictures(portfolio_params)
    portfolio_pictures_ids = portfolio_params[:picture_ids].try(:split, ',').try(:map, &:to_i)
    personal_picture_id = portfolio_params[:personal_picture_id]
    Image.update_portfolio(self, personal_picture_id, portfolio_pictures_ids)
  end

  def assign_unique_path
    update_attributes!(path: unique_path) unless path.present?
  end

  private

  def unique_path
    preferred_path = URI.encode(designer.name.parameterize.underscore)
    existing_paths = Portfolio.where('path LIKE ?', "#{ preferred_path }%").pluck(:path)
    UniquePathGenerator.generate(preferred_path, existing_paths)
  end
end
