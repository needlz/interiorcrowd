class DocumentsController < ApplicationController
    
    def create
      params[:image] = {}
      params[:image][:image] = params[:photo]
      params.require(:image).permit(:image)
      
      @image = Image.new(params[:image])
      
      if @image.save
          render :json =>  "#{@image.image.url(:thumb)},#{@image.id}"
      else
          render :json => {:msg => "Upload Failed", :error => @image.error}
      end
    end

end


