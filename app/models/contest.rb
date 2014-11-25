class Contest < ActiveRecord::Base
  self.per_page = 10
  
  CONTEST_DESIGN_BUDGETS = {1 => "$0-$200", 2 => "$201-$500", 3 => "$501-1000", 4 => "$1000+"}
  CONTEST_DESIGN_BUDGET_PLAN = {1 => "$99", 2 => "$199", 3 => "$299"}

  has_many :contests_appeals
  has_many :appeals, through: :contests_appeals
  has_many :liked_external_examples, class_name: 'ImageLink'

  has_many :images
  has_many :liked_examples, -> { liked_examples }, class_name: 'Image'
  has_many :space_images, -> { space_images }, class_name: 'Image'

  belongs_to :client
  belongs_to :design_category
  belongs_to :design_space
  has_many :contest_requests

  scope :by_page, ->(page) { paginate(page: page).order(created_at: :desc) }

  def self.options_from_hash(options)
    {
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
          designer_level: options[:design_style].try(:[], :designer_level),
          desirable_colors: options[:design_style].try(:[], :desirable_colors),
          undesirable_colors: options[:design_style].try(:[], :undesirable_colors)
      },
      contest_associations: {
          appeals: options[:design_style].try(:[], :appeals),
          space_image_ids: (options[:design_space][:document_id].split(',').map(&:strip).map(&:to_i) if options[:design_space].try(:[], :document_id)),
          liked_example_ids: (options[:design_style][:document_id].split(',').map(&:strip).map(&:to_i) if options[:design_style].try(:[], :document_id)),
          example_links: (options[:design_style][:ex_links].split(',').map(&:strip)  if options[:design_style].try(:[], :ex_links))
      }
    }
  end

  def add_space_images(image_ids)
    add_images(image_ids, Image::SPACE)
  end

  def add_example_images(image_ids)
    add_images(image_ids, Image::LIKED_EXAMPLE)
  end

  def update_appeals(options)
    Appeal.all.each do |appeal|
      contest_appeal = contests_appeals.where(appeal_id: appeal.id).first_or_initialize
      if options[appeal.identifier]
        contest_appeal.assign_attributes(options[appeal.identifier])
        contest_appeal.save
      end
    end
  end

  def update_external_examples(urls)
    return unless urls
    liked_external_examples.destroy_all
    urls.each do |url|
      liked_external_examples << ImageLink.new(url: url)
    end
  end

  def update_space_images(image_ids)
    update_images(image_ids, Image::SPACE)
  end

  def update_example_images(image_ids)
    update_images(image_ids, Image::LIKED_EXAMPLE)
  end

  def update_associations(contest_associations)
    return unless contest_associations
    update_appeals(contest_associations[:appeals]) if contest_associations[:appeals]
    update_external_examples(contest_associations[:example_links]) if contest_associations[:example_links]
    update_space_images(contest_associations[:space_image_ids]) if contest_associations[:space_image_ids]
    update_example_images(contest_associations[:liked_example_ids]) if contest_associations[:liked_example_ids]
  end

  private

  def add_images(image_ids, kind)
    images = Image.where(id: image_ids)
    images.each do |image|
      image.update_attributes(contest_id: id, kind: kind)
    end
  end

  def update_images(image_ids, kind)
    old_ids = images.pluck(:id)
    ids_to_remove = old_ids - image_ids
    ids_to_add = image_ids - old_ids
    Image.where(id: ids_to_remove).destroy_all
    add_images(ids_to_add, kind)
  end

end