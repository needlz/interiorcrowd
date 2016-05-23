class RoomDesignsController < ApplicationController
  def create
    @room_design = RoomDesign.new(room_params)
    @room_design.contest_request = ContestRequest.find(params[:contest_request_id])
    if @room_design.save!
      render json: { new_room_html: render_to_string(partial: 'designer_center_requests/edit/room',
                                                   locals: { room: @room_design }) }
    else
      render status: 500, json: {}
    end
  end

  private

  def room_params
    params.require(:room_design).permit(:room)
  end
end
