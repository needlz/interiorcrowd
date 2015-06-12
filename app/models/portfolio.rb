# == Schema Information
#
# Table name: portfolios
#
#  id                      :integer          not null, primary key
#  designer_id             :integer          not null
#  years_of_experience     :integer
#  education_gifted        :boolean
#  education_school        :boolean
#  education_apprenticed   :boolean
#  school_name             :text
#  degree                  :text
#  awards                  :text
#  style_description       :text
#  about                   :text
#  path                    :text
#  modern_style            :boolean          default(FALSE)
#  vintage_style           :boolean          default(FALSE)
#  traditional_style       :boolean          default(FALSE)
#  contemporary_style      :boolean          default(FALSE)
#  coastal_style           :boolean          default(FALSE)
#  global_style            :boolean          default(FALSE)
#  eclectic_style          :boolean          default(FALSE)
#  hollywood_glam_style    :boolean          default(FALSE)
#  midcentury_modern_style :boolean          default(FALSE)
#  transitional_style      :boolean          default(FALSE)
#  rustic_elegance_style   :boolean          default(FALSE)
#  color_pop_style         :boolean          default(FALSE)
#  background_id           :integer
#  cover_width             :integer
#  cover_x_percents_offset :float
#  cover_y_percents_offset :float
#

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
