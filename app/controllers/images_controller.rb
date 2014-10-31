class ImagesController < ApplicationController
    
  def create
    params[:image] = {}
    params[:image][:image] = params[:photo]
    params.require(:image).permit(:image)

    @image = Image.new(params[:image])

    if @image.save
        render :json =>  "#{@image.image.url(:medium)},#{@image.id}"
    else
        render :json => {:msg => "Upload Failed", :error => @image.errors}
    end
  end

  def show
    @image = Image.find(params[:id])
    send_file @image.image.path, :type => @image.image.content_type,
              :disposition => 'inline'
  end

end


