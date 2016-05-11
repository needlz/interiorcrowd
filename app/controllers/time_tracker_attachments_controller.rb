class TimeTrackerAttachmentsController < ApplicationController
  before_action :set_time_tracker, :set_designer, :authorize

  def create
    begin
      attachment = Image.where(uploader_role: @designer.role, uploader_id: @designer.id).find(params[:id])
      @time_tracker.attachments << attachment
    rescue StandardError => exception
      log_error(exception)
    end
    respond_to do |format|
      format.json do
        if exception
          render json: { error: 'Internal error' }
        else
          render json: { created: attachment.id,
                         submitted_at: attachment.created_at.strftime(t('time_tracker_attachments.submit_date_format')) }
        end
      end
    end
  end

  def destroy
    begin
      attachment = @time_tracker.attachments.find(params[:id])
      attachment_id = attachment.id
      @time_tracker.attachments.delete(attachment)
      attachment.destroy
    rescue StandardError => exception
      log_error(exception)
    end
    respond_to do |format|
      format.json do
        if error_message
          render json: { error: 'Internal error' }
        else
          render json: { deleted: attachment_id }
        end
      end
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

