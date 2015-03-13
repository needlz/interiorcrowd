class ContestShortDetails
  include ActionView::Helpers::DateHelper

  attr_reader :id, :name, :design_category, :design_space, :days_left, :price, :days_count, :days_till_end, :status,
              :client_name

  def initialize(contest)
    @id = contest.id
    @name = contest.project_name
    @design_category = DesignCategoryView.new(contest.design_category).name
    @design_space = contest.design_space.name
    @days_count = contest.days_left
    @days_till_end = get_days_till_end(contest)
    @days_left = "#{ days_till_end}#{ ' days' if contest.fulfillment? }"
    @price = I18n.t('designer_center.responses.item.price',
                    price: BudgetPlan.find(contest.budget_plan).price)
    @status = contest.status
    @client_name = contest.client.name
  end

  def get_days_till_end(contest)
    contest.fulfillment? ?  '—' : days_count.to_s
  end

end
