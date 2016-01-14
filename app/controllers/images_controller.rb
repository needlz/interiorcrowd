class ImagesController < ApplicationController
    
  def create
    @image = Image.new(params[:image].merge(uploader_role: current_user.role, uploader_id: current_user.try(:id)))
    if @image.save
      render json: { files: [ file_details(@image) ] }
    else
      render json: { msg: "Upload Failed", error: @image.errors }
    end
  end

  def show
    @image = Image.find(params[:id])
    send_file @image.image.path, type: @image.image.content_type,
              disposition: 'inline'
  end

  private

  def file_details(file)
    file.thumbnail.merge(original_name: params[:image][:image].original_filename)
  end

end
