class ContestShortDetails

  attr_reader :id, :name, :design_category, :design_space, :days_left, :price

  def initialize(contest)
    @id = contest.id
    @name = contest.project_name
    @design_category = contest.design_category.name
    @design_space = contest.design_space.name
    @days_left = I18n.t('designer_center.contests_preview.days_left',
                        days: contest.days_left)
    @price = I18n.t('designer_center.responds.item.price',
                    price: BudgetPlan.find(contest.budget_plan).price)
  end

end
