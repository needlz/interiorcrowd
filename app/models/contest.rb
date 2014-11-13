class Contest < ActiveRecord::Base
  self.per_page = 10
  
  CONTEST_DESIGN_BUDGETS = {1 => "$0-$200", 2 => "$201-$500", 3 => "$501-1000", 4 => "$1000+"}
  CONTEST_DESIGN_BUDGET_PLAN = {1 => "$99", 2 => "$199", 3 => "$299"}

  has_many :contests_appeals
  has_many :appeals, through: :contests_appeals
  has_many :liked_external_examples, class_name: 'ImageLink'
  has_many :contests_images
  has_many :example_contests_images, ->{ where(kind: ContestsImage::LIKED_EXAMPLE) }, class_name: 'ContestsImage'
  has_many :space_contests_images, ->{ where(kind: ContestsImage::SPACE) }, class_name: 'ContestsImage'
  has_many :liked_examples, through: :example_contests_images, class_name: 'Image', source: :image
  has_many :space_images, through: :space_contests_images, class_name: 'Image', source: :image

  belongs_to :client
  belongs_to :design_category
  belongs_to :design_space

  scope :by_page, ->(page) { paginate(page: page).order(created_at: :desc) }

  def add_appeals(options)
    Appeal.all.each do |appeal|
      contests_appeals << ContestsAppeal.new(appeal_id: appeal.id,
                                             contest_id: id,
                                             reason: options.try(:[], appeal.identifier).try(:[], :reason),
                                             value: options.try(:[], appeal.identifier).try(:[], :value))
    end
  end

  def add_external_examples(urls)
    urls.each do |url|
      liked_external_examples << ImageLink.new(url: url)
    end
  end

  def add_images(image_ids, kind)
    image_ids.each do |image_id|
      contests_images << ContestsImage.new(image_id: image_id, kind: kind)
    end
  end
end