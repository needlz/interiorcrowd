class TimeTrackerController < ApplicationController
  before_action :check_designer, only: [:designers_show, :suggest_hours]

  def clients_show
    return unless check_client

    @contest = Contest.find(params[:id])

    return raise_404 unless @contest.client == current_user
    return raise_404 unless check_contest_status

    @time_tracker = TimeTrackerView.new(@contest.time_tracker)
  end

  def designers_show
    @contest = Contest.find(params[:contest_id])
    contests_designer = @contest.response_winner.designer if @contest.response_winner

    return raise_404 unless contests_designer == current_user
    return raise_404 unless check_contest_status

    @contest_request = @contest.response_of(current_user)
    @navigation = "Navigation::DesignerCenter::#{ @contest.status.camelize }".constantize.new(:time_tracker,
                                                                                              contest: @contest,
                                                                                              contest_request: @contest_request)
    @time_tracker = TimeTrackerView.new(@contest.time_tracker)
    @designer_activity = DesignerActivity.new()
    @designer_activities = @contest.time_tracker.designer_activities.sort_by(& :start_date).group_by do |activity|
      activity.start_date.at_end_of_week
    end

  end

  def suggest_hours
    contest = Contest.find(params[:contest_id])
    contest_request = contest.response_winner

    raise ArgumentError unless params[:suggested_hours]

    return raise_404 unless current_user == contest_request.designer

    time_tracker = contest.time_tracker
    time_tracker.with_lock do
      hours_suggested = time_tracker.hours_suggested + params[:suggested_hours].to_i
      if time_tracker.update_attributes({hours_suggested: hours_suggested})
        render status: 200, json: hours_suggested
      else
        raise ArgumentError
      end
    end
  rescue ArgumentError
    render status: 500, json: t('time_tracker.designer.request_send_error')
  end

  def purchase_confirm
    return unless check_client

    @hours = params[:hours].to_i
    @contest = Contest.find(params[:id])

    return raise_404 unless @contest.client == current_user
    return raise_404 unless check_contest_status

    @time_tracker = TimeTrackerView.new(@contest.time_tracker, @hours)
  end

  def show_invoice
    return unless check_client

    @hours = params[:hours].to_i
    @contest = Contest.find(params[:id])

    return raise_404 unless @contest.client == current_user
    return raise_404 unless check_contest_status

    @card = CreditCardView.new(current_user.primary_card)
    @contest.time_tracker.update_attributes({ hours_actual: @hours + @contest.time_tracker.hours_actual, hours_suggested: 0 })
    @time_tracker = TimeTrackerView.new(@contest.time_tracker, @hours)
  end

  private

  def check_contest_status
    %w[fulfillment final_fulfillment].include? @contest.status
  end
end
