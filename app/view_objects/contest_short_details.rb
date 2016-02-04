class ContestShortDetails
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  attr_reader :id, :name, :package_name, :design_spaces, :days_left, :price, :days_count, :days_till_end, :status,
              :client_name, :status_name, :continue_path, :continue_label, :progress, :unfinished_step_path,
              :submissions_count, :rooms_short_name, :rooms_popover_attributes, :design_spaces_list, :design_space_possesive_name
  delegate :response_winner, :completed?, :winner_selection?, to: :contest

  def initialize(contest)
    @contest = contest
    @id = contest.id
    @submissions_count = contest.requests.submitted.count
    @name = contest.project_name || 'My New Project'
    package = PackageView.new(contest.package)
    @package_name = package.name if package
    @design_spaces = contest.design_spaces
    @days_count = calculate_days_count
    @days_till_end = get_days_till_end
    @days_left = days_till_end ? "#{ days_till_end }#{ ' days' if contest.winner_collaboration? }" : nil
    @price = I18n.t('designer_center.responses.item.price', price: package.price) if contest.package
    @status = contest.status
    @client_name = contest.client.name
    @status_name = I18n.t('client_center.statuses.' + status)
    @contest_view = ContestView.new(contest_attributes: contest)
    @progress = "#{ calculate_progress }% completed"
    if contest.completed?
      @continue_path = client_center_entry_path(id: contest.id)
      @continue_label = I18n.t('designer_center.responses.item.go')
    else
      @continue_path = ContestCreationWizard.incomplete_step_path(contest)
      @continue_label = I18n.t('designer_center.responses.item.finish')
    end
    @design_spaces_list = @design_spaces.map(&:full_name).join(', ')
    if @design_spaces.length > 1
      @rooms_popover_attributes = { class: 'clickable',
                                    data: { toggle: 'popover', content: @design_spaces.map(&:full_name).join(', ') } }
      @design_space_possesive_name = 'rooms'
      @rooms_short_name = 'Multiple'
    else
      @rooms_short_name = @design_spaces.first.full_name
      @rooms_popover_attributes = {}
      @design_space_possesive_name = @rooms_short_name
    end
  end

  def steps_completed
    result = 0
    (0..(ContestCreationWizard.steps_count - 1)).each do |step|
      (result = result + 1) if ContestCreationWizard.finished_step?(contest, step)
    end
    result
  end

  def get_days_till_end
    return '—' unless (contest.submission? || contest.winner_selection?)
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

  def calculate_progress
    (steps_completed.to_f / ContestCreationWizard.steps_count * 100).to_i
  end

end
