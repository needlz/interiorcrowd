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

  def self.create_from_options(options)
    contest = new(options.contest)
    contest.transaction do
      contest.save!
      contest.on_update_from_options(options)
    end
    contest
  end

  def update_from_options(options)
    transaction do
      update_attributes(options.contest) if options.contest
      on_update_from_options(options)
    end
  end

  def on_update_from_options(options)
    return unless options
    update_appeals(options.appeals) if options.appeals
    update_external_examples(options.example_links) if options.example_links
    update_space_images(options.space_image_ids) if options.space_image_ids
    update_example_images(options.liked_example_ids) if options.liked_example_ids
  end

  private

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
    Image.update_ids(id, image_ids, Image::SPACE)
  end

  def update_example_images(image_ids)
    Image.update_ids(id, image_ids, Image::LIKED_EXAMPLE)
  end

end