class DesignerActivitiesController < ApplicationController

  def create
    tracker = Contest.find(params[:contest_id]).time_tracker

    activity_form = DesignerActivityForm.new(params)

    activity = tracker.designer_activities.create(activity_form.activity_attributes)
    if activity_form.activity_comment_attributes.try(:[], :text).present?
      activity.comments.create(activity_form.activity_comment_attributes.merge(author: current_user))
    end

    week = activity.start_date.at_end_of_week
    week_id = week.at_beginning_of_week.to_i

    if activity
      render status: :ok, json: { new_activity_html: render_to_string(partial: 'time_tracker/activity',
                                                                      locals: { activity_view: DesignerActivityView.new(activity, current_user),
                                                                                collapsed: false }),
                                  id: activity.id,
                                  date_range_id: week_id,
                                  date_range_header_html: render_to_string(partial: 'time_tracker/group_header',
                                                                           locals: { week: week,
                                                                                     activities: [],
                                                                                     collapsed: false })}
    else
      render status: :server_error, json: t('time_tracker.designer.request_send_error')
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

  def designer_activity_params
    params.require(:designer_activity).permit!(:start_date, :due_date, :task, :hours)
  end

end
