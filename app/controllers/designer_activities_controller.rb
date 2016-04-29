class DesignerActivitiesController < ApplicationController

  def create
    tracker = Contest.find(params[:contest_id]).time_tracker

    if tracker.designer_activities.create(params[:designer_activity])
      render status: :ok, json: DesignerActivity.last.id
    else
      render status: :server_error, json: t('time_tracker.designer.request_send_error')
    end
  end
end
