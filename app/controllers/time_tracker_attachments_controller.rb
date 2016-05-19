class TimeTrackerAttachmentsController < ApplicationController
  before_action :set_time_tracker, :set_designer, :authorize

  def create
    begin
      attachment = Image.where(uploader_role: @designer.role, uploader_id: @designer.id).find(params[:id])
      @time_tracker.attachments << attachment
    rescue StandardError => exception
      log_error(exception)
    end
    if exception
      render status: :server_error, json: { error_message: 'Internal error' }
    else
      render json: { created: attachment.id,
                     submitted_at: attachment.created_at.strftime(t('time_tracker.attachments.submit_date_format')) }
    end
  end

  private

  def set_time_tracker
    @time_tracker = Contest.find(params[:contest_id]).time_tracker
  end

  def authorize
    return unless EditTimeTrackerPolicy.for_designer(@designer).edit(@time_tracker).can?
  end
end

