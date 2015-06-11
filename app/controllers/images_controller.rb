class ImagesController < ApplicationController
    
  def create
    @image = Image.new(params[:image].merge(uploader_role: current_user.role, uploader_id: current_user.try(:id)))
    if @image.save
      render json: { files: [@image.thumbnail] }
    else
      render json: { msg: "Upload Failed", error: @image.errors }
    end
  end

  def show
    @image = Image.find(params[:id])
    send_file @image.image.path, type: @image.image.content_type,
              disposition: 'inline'
  end

end
