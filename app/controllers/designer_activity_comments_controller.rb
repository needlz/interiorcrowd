class DesignerActivityCommentsController < ApplicationController

  def create
    tracker = Contest.find(params[:contest_id]).time_tracker
    activity = tracker.designer_activities.find(params[:designer_activity_id])

    comment_params = DesignerActivityCommentForm.new(params).comment_params
    activity.comments.create(comment_params.merge(author: current_user))

    if activity
      render status: :ok, json: { new_activity_html: render_to_string(partial: 'time_tracker/activity',
                                                                      locals: { activity_view: DesignerActivityView.new(activity, current_user),
                                                                                collapsed: false }) }
    else
      render status: :server_error, json: t('time_tracker.designer.request_send_error')
    end
  end

end
