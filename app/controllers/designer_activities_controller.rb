class DesignerActivitiesController < ApplicationController

  def create
    tracker = Contest.find(params[:contest_id]).time_tracker

    activity_form = DesignerActivityForm.new(params)

    activity = tracker.designer_activities.create(activity_form.activity_attributes)
    activity.comments.create(activity_form.activity_comment_attributes.merge(author: current_user))

    if activity
      render status: :ok, json: { new_activity_html: render_to_string(partial: 'time_tracker/activity',
                                                                      locals: { activity: activity }) }
    else
      render status: :server_error, json: t('time_tracker.designer.request_send_error')
    end
  end

  private

  def designer_activity_params
    params.require(:designer_activity).permit!(:start_date, :due_date, :task, :hours)
  end

end
