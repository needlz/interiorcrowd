class DesignerActivitiesController < ApplicationController

  def create
    begin
      tracker = Contest.find(params[:contest_id]).time_tracker

      activity_form = DesignerActivityForm.new(params)

      activities_creation_results = CreateDesignerActivities.perform(activity_form: activity_form,
                                                                      time_tracker: tracker,
                                                                      user: current_user).result
    rescue StandardError => e
      log_error(e)
      render status: :server_error, json: t('time_tracker.designer.request_send_error')
    else
      result = DesignerActivityCreationResult.new(creation_result: activities_creation_results,
                                                  view_context: view_context,
                                                  time_tracker: tracker,
                                                  user: current_user)
      render status: :ok, json: result.to_hash
    end
  end

  def read
    tracker = Contest.find(params[:contest_id]).time_tracker
    activity = tracker.designer_activities.find(params[:id])
    comments = activity.comments.where.not(author_id: current_user.id, author_type: current_user.class.name)
    comments.update_all(read: true)
    render json: { saved: true, activity_id: activity.id }
  end

end
