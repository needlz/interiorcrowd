class Contest < ActiveRecord::Base
  self.per_page = 10
  
  CONTEST_DESIGN_BUDGETS = {1 => "$0-$200", 2 => "$201-$500", 3 => "$501-1000", 4 => "$1000+"}
  CONTEST_DESIGN_BUDGET_PLAN = {1 => "$99", 2 => "$199", 3 => "$299"}

  has_many :contests_appeals
  has_many :appeals, through: :contests_appeals

  belongs_to :client
  belongs_to :design_category
  belongs_to :design_space

  scope :by_page, ->(page) { paginate(page: page).order(created_at: :desc) }
end