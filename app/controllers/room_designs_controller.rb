class RoomDesignsController < ApplicationController
  def create
    @room_design = RoomDesign.new(room_params)
    @room_design.save!
    redirect_to root_path
  end

  private

  def room_params
    params.require(:contest_request_id)
    params.require(:room).permit(:room)
  end
end