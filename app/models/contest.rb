class Contest < ActiveRecord::Base
  self.per_page = 10
  
  CONTEST_DESIGN_BUDGETS = {1 => "$0-$200", 2 => "$201-$500", 3 => "$501-1000", 4 => "$1000+"}
  CONTEST_DESIGN_BUDGET_PLAN = {1 => "$99", 2 => "$199", 3 => "$299"}

  has_many :contests_appeals
  has_many :appeals, through: :contests_appeals
  has_many :image_links

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

  def add_image_links(urls)
    urls.each do |url|
      image_links << ImageLink.new(url: url)
    end
  end
end