class FinalNoteToDesignerController < ApplicationController
  before_filter :set_client

  def create
    contest_request = @client.contest_requests.find(params[:contest_request_id])
    creation = CreateFinalNoteToDesigner.new(contest_request: contest_request,
                                             final_note_attributes: final_note_params,
                                             client: @client)
    creation.perform
    render json: { created: true }
  end

  private

  def final_note_params
    params.require(:final_note).permit(:text)
  end

end
