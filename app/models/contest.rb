class Contest < ActiveRecord::Base
  self.per_page = 10
  
  CONTEST_DESIGN_BUDGETS = {1 => "$0-$200", 2 => "$201-$500", 3 => "$501-1000", 4 => "$1000+"}
  CONTEST_DESIGN_BUDGET_PLAN = {1 => "$99", 2 => "$199", 3 => "$299"}

  APPEAL_SCALES = [
    { start: :feminine, end: :masculine },
    { start: :elegant, end: :eclectic },
    { start: :traditional, end: :modern },
    { start: :conservative, end: :bold },
    { start: :muted, end: :colorful },
    { start: :timeless, end: :trendy },
    { start: :fancy, end: :playful }
  ]

  belongs_to :client
end