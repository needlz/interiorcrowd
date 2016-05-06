class DesignerActivitiesController < ApplicationController

  def create
    begin
      tracker = Contest.find(params[:contest_id]).time_tracker

      activity_form = DesignerActivityForm.new(params)

      activities = activity_form.activities_params.map { |activity_params|
        activity = tracker.designer_activities.create!(designer_activity_params(activity_params))
        comment_attributes = activity_params.try(:[], :comments)
        if comment_attributes.try(:[], :text).present?
          activity.comments.create(comment_attributes.merge(author: current_user))
        end
        activity
      }

      week = activities.first.start_date.at_end_of_week
      week_id = week.at_beginning_of_week.to_i
    rescue StandardError => e
      log_error(e)
      render status: :server_error, json: t('time_tracker.designer.request_send_error')
    else
      responses = activities.map { |activity|
        { new_activity_html: render_to_string(partial: 'time_tracker/activity',
                                              locals: { activity_view: DesignerActivityView.new(activity, current_user),
                                                        collapsed: false }),
          id: activity.id,
          date_range_id: week_id,
          date_range_header_html: render_to_string(partial: 'time_tracker/group_header',
                                                   locals: { week: week,
                                                             activities: [],
                                                             collapsed: false }) }
      }
      render status: :ok, json: { activities: responses }
    end
  end

  def read
    tracker = Contest.find(params[:contest_id]).time_tracker
    activity = tracker.designer_activities.find(params[:id])
    comments = activity.comments.where.not(author_id: current_user.id, author_type: current_user.class.name)
    comments.update_all(read: true)
    render json: { saved: true, activity_id: activity.id }
  end

  private

  def designer_activity_params(activity_params)
    activity_params.permit(:start_date, :due_date, :task, :hours)
  end

end
