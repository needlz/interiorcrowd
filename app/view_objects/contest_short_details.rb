class ContestShortDetails
  include ActionView::Helpers::DateHelper

  attr_reader :id, :name, :design_category, :design_space, :days_left, :price

  def initialize(contest)
    @id = contest.id
    @name = contest.project_name
    @design_category = contest.design_category.name
    @design_space = contest.design_space.name
    @days_left = I18n.t('designer_center.contests_preview.days_left',
                        days: distance_of_time_in_words(Time.current, contest.phase_end))
    @price = I18n.t('designer_center.responses.item.price',
                    price: BudgetPlan.find(contest.budget_plan).price)
  end

end
