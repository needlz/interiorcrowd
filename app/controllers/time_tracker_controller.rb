class TimeTrackerController < ApplicationController
  before_action :check_designer, only: [:designer_view, :suggest_hours]

  def client_view
    return unless check_client

    @contest = Contest.find(params[:id])

    return raise_404 unless @contest.client == current_user
    return raise_404 unless check_contest_status

    @time_tracker = TimeTrackerView.new(@contest.time_tracker)
    @activities_groups_holder = activities_grouper(@time_tracker)
  end

  def designer_view
    @contest = Contest.find(params[:contest_id])
    contests_designer = @contest.response_winner.designer if @contest.response_winner

    return raise_404 unless contests_designer == current_user
    return raise_404 unless check_contest_status

    @contest_request = @contest.response_of(current_user)
    @navigation = "Navigation::DesignerCenter::#{ @contest.status.camelize }".constantize.new(:time_tracker,
                                                                                              contest: @contest,
                                                                                              contest_request: @contest_request)
    @time_tracker = TimeTrackerView.new(@contest.time_tracker)
    @new_activity_form = DesignerActivityForm.new(DesignerActivity.new)
    @activities_groups_holder = activities_grouper(@time_tracker)
  end

  def suggest_hours
    contest = Contest.find(params[:contest_id])
    contest_request = contest.response_winner

    return raise_404 unless contest_request
    return raise_404 unless current_user == contest_request.designer
    raise ArgumentError unless params[:suggested_hours]

    time_tracker = contest.time_tracker
    time_tracker.with_lock do
      hours_suggested = time_tracker.hours_suggested + params[:suggested_hours].to_i
      if time_tracker.update_attributes({hours_suggested: hours_suggested})
        Jobs::Mailer.schedule(:hours_added_to_client_project, [contest.id])
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
    @time_tracker = TimeTrackerView.new(@contest.time_tracker, @hours)

    begin
      ChargeHourlyPayment.new(@contest, @hours).perform
    rescue StandardError => e
      log_error(e)
      flash[:error] = e.message
      redirect_to time_tracker_client_center_entry_path
    end

  end

  private

  def check_contest_status
    %w[fulfillment final_fulfillment].include? @contest.status
  end

  def activities_grouper(time_tracker)
    activities_views = time_tracker.designer_activities.includes(comments: [:author]).map{ |activity| DesignerActivityView.new(activity, current_user) }
    DesignerActivitiesGrouper.new(activities_views, @time_tracker)
  end

end
