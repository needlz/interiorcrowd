require 'pdf_thumbnail'
class ImagesController < ApplicationController
    
  def create
    PdfThumbnail.process(params[:image])
    @image = Image.new(params[:image])
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
