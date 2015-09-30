class ContestShortDetails
  include ActionView::Helpers::DateHelper

  attr_reader :id, :name, :package_name, :design_space, :days_left, :price, :days_count, :days_till_end, :status,
              :client_name, :status_name
  delegate :response_winner, to: :contest

  def initialize(contest)
    @contest = contest
    @id = contest.id
    @name = contest.project_name
    @package_name = PackageView.new(contest.package).name
    @design_space = contest.design_space.full_name
    @days_count = calculate_days_count
    @days_till_end = get_days_till_end
    @days_left = "#{ days_till_end }#{ ' days' if contest.winner_collaboration? }"
    @price = I18n.t('designer_center.responses.item.price',
                    price: BudgetPlan.find(contest.budget_plan).price)
    @status = contest.status
    @client_name = contest.client.name
    @status_name = I18n.t('client_center.statuses.' + status)
  end

  def get_days_till_end
    return '—' unless days_count
    if days_count >= 1
      days_count.to_s
    else
      '< 1'
    end
  end

  private

  attr_reader :contest

  def calculate_days_count
    return nil if !contest.phase_end || contest.phase_end < Time.current
    days = (contest.phase_end - Time.current) / 1.day
    if days > 2
      days.floor
    elsif days > 1
      days.round
    else
      0
    end
  end

end
