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
  has_many :example_links
  has_many :portfolio_awards
  after_create  { |portfolio| portfolio.assign_unique_path}

  def complete?
    path.present?
  end

  def update_pictures(portfolio_params)
    portfolio_pictures_ids = portfolio_params[:picture_ids].try(:split, ',').try(:map, &:to_i)
    personal_picture_id = portfolio_params[:personal_picture_id]
    Image.update_portfolio(self, personal_picture_id, portfolio_pictures_ids)
  end

  def update_links(links)
    return unless links
    example_links.destroy_all
    links.each do |link|
      example_links.create!(url: link) if link.present?
    end
  end

  def update_awards(new_awards)
    return unless new_awards
    portfolio_awards.destroy_all
    new_awards.each do |award|
      portfolio_awards.create!(name: award) if award.present?
    end
  end

  def assign_unique_path
    update_attributes!(path: unique_path) unless path.present?
  end

  def visible_to(user)
    return true if !designer.has_role? :test
    return true if user.can_view_test_pages?
    false
  end

  private

  def unique_path
    preferred_path = URI.encode(designer.name.parameterize.underscore)
    existing_paths = Portfolio.where('path LIKE ?', "#{ preferred_path }%").pluck(:path)
    UniquePathGenerator.generate(preferred_path, existing_paths)
  end
end
