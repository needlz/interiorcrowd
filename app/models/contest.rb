class Contest < ActiveRecord::Base
  self.per_page = 10
  
  CONTEST_DESIGN_BUDGETS = {1 => "$0-$200", 2 => "$201-$500", 3 => "$501-1000", 4 => "$1000+"}
  CONTEST_DESIGN_BUDGET_PLAN = {1 => "$99", 2 => "$199", 3 => "$299"}

  has_many :contests_appeals
  has_many :appeals, through: :contests_appeals
  has_many :liked_external_examples, class_name: 'ImageLink'

  has_many :liked_examples, -> { liked_examples }, class_name: 'Image'
  has_many :space_images, -> { space_images }, class_name: 'Image'

  belongs_to :client
  belongs_to :design_category
  belongs_to :design_space
  has_many :contest_requests

  scope :by_page, ->(page) { paginate(page: page).order(created_at: :desc) }

  def self.options_from_hash(options)
    HashWithIndifferentAccess.new({
      contest: {
          design_category_id: options[:design_brief].try(:[], :design_category),
          design_space_id: options[:design_brief].try(:[], :design_area),
          space_length: options[:design_space].try(:[], :length),
          space_width: options[:design_space].try(:[], :width),
          space_height: options[:design_space].try(:[], :height),
          space_budget: options[:design_space].try(:[], :f_budget),
          feedback: options[:design_space].try(:[], :feedback),
          budget_plan: options[:preview].try(:[], :b_plan),
          project_name: options[:preview].try(:[], :contest_name),
      }.merge(options[:design_style] || {}),
      contest_associations: {
          space_image_ids: (options[:design_space][:document_id].split(',').map(&:strip).map(&:to_i) if options[:design_space].try(:[], :document_id)),
          space_image_urls: (options[:design_space][:document].split(',').map(&:strip) if options[:design_space].try(:[], :document)),
          liked_example_ids: (options[:design_style][:document_id].split(',').map(&:strip).map(&:to_i) if options[:design_style].try(:[], :document_id)),
          liked_example_urls: (options[:design_style][:document].split(',').map(&:strip) if options[:design_style].try(:[], :document)),
          example_links: (options[:design_style][:ex_links].split(',').map(&:strip)  if options[:design_style].try(:[], :ex_links))
      }
    })
  end

  def add_appeals(options)
    Appeal.all.each do |appeal|
      contests_appeals << ContestsAppeal.new(appeal_id: appeal.id,
                                             contest_id: id,
                                             reason: options.try(:[], appeal.identifier).try(:[], :reason),
                                             value: options.try(:[], appeal.identifier).try(:[], :value))
    end
  end

  def add_external_examples(urls)
    return unless urls
    urls.each do |url|
      liked_external_examples << ImageLink.new(url: url)
    end
  end

  def add_space_images(image_ids)
    add_images(image_ids, Image::SPACE)
  end

  def add_example_images(image_ids)
    add_images(image_ids, Image::LIKED_EXAMPLE)
  end

  private

  def add_images(image_ids, kind)
    images = Image.where(id: image_ids)
    images.each do |image|
      image.update_attributes(contest_id: id, kind: kind)
    end
  end

end