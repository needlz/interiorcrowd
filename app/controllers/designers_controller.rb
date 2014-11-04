class DesignersController < ApplicationController
  before_filter :check_designer, :only => [:welcome, :lookbook, :preview_lookbook]
  before_action :set_designer, only: [:show, :edit, :update, :destroy]

  def index
    @designers = Designer.all
  end

  def thank_you

  end 
  
  def show
  end

  def new
    session[:exlnks] = nil
    @designer = Designer.new
    @designer_images = nil
  end

  def edit
  end

  def create
    user_ps = params[:designer][:password]
    params[:designer][:password] = Client.encrypt(params[:designer][:password])
    params[:designer][:password_confirmation] = Client.encrypt(params[:designer][:password_confirmation])
    params[:designer][:ex_links] = params[:exlinks].reject { |c| c.empty? }.join(',')
    session[:exlnks] = params[:designer][:ex_links]
    @designer = Designer.new(designer_params)
    respond_to do |format|
      if @designer.save
        session[:exlnks] = nil
        session[:designer_id] = @designer.id 
        ICrowd.designer_registration(@designer, user_ps).deliver
        format.html { redirect_to welcome_designer_path(@designer), notice: 'Designer was successfully created.' }
        format.json { render action: 'show', status: :created, location: @designer }
      else
        @designer_images = params[:designer_image]
        flash[:error] = @designer.errors.full_messages.join("</br>") 
        format.html { render action: 'new' }
        format.json { render json: @designer.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @designer.update(designer_params)
        format.html { redirect_to @designer, notice: 'Designer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @designer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @designer.destroy
    respond_to do |format|
      format.html { redirect_to designers_url }
      format.json { head :no_content }
    end
  end
  
  
  def welcome
    render
  end
  
  def lookbook
    if request.method == "POST"
      session[:lookbook] = params
      redirect_to preview_lookbook_designer_path(params[:id])
    else
      if session[:lookbook].present?
        image_paths = session[:lookbook]['lookbook_photo']['document'].split(',')
        image_ids = session[:lookbook]['lookbook_photo']['document_id'].split(',')
        image_titles = session[:lookbook]['lookbook_photo']['photo_title']

        link_urls = session[:lookbook]['lookbook_link']['links']
        link_titles = session[:lookbook]['lookbook_link']['link_title']

        feedback = session[:lookbook]['feedback']
      else
        lookbook = Lookbook.find_by_designer_id_and_contest_id(session[:designer_id], params[:id])
        if lookbook
          pictures = lookbook.lookbook_details.includes(:image).uploaded_pictures.order(id: :asc)
          if pictures.present?
            image_ids = []
            image_paths = []
            image_titles = []
            pictures.each do |lookbook_document|
              image = lookbook_document.image
              image_paths << image.image.url(:medium)
              image_ids << image.id
              image_titles << lookbook_document.description
            end
          end
          links = lookbook.lookbook_details.external_pictures.order(id: :asc)
          link_urls = links.pluck(:url)
          link_titles = links.pluck(:description)
          feedback = lookbook.feedback
        end
      end

      @lookbook_view = LookbookView.new(image_ids, image_paths, image_titles, link_urls, link_titles, feedback)
    end  
  end
  
  def preview_lookbook
    redirect_to lookbook_designer_path(params[:id]) if session[:lookbook].blank?
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_designer
      @designer = Designer.find(params[:id]) if params[:id].present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def designer_params
      params[:designer]
    end
end
