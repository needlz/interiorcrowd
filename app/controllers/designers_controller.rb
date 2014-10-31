class DesignersController < ApplicationController
  before_filter :check_designer, :only => [:welcome, :lookbook, :preview_lookbook]
  before_action :set_designer, only: [:show, :edit, :update, :destroy]

  # GET /designers
  # GET /designers.json
  def index
    @designers = Designer.all
  end

  def thank_you

  end 
  
  # GET /designers/1
  # GET /designers/1.json
  def show
  end

  # GET /designers/new
  def new
    session[:exlnks] = nil
    @designer = Designer.new
    @designer_images = nil
  end

  # GET /designers/1/edit
  def edit
  end

  # POST /designers
  # POST /designers.json
  def create
    #raise  params[:exlinks].inspect
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
  
  

  # PATCH/PUT /designers/1
  # PATCH/PUT /designers/1.json
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

  # DELETE /designers/1
  # DELETE /designers/1.json
  def destroy
    @designer.destroy
    respond_to do |format|
      format.html { redirect_to designers_url }
      format.json { head :no_content }
    end
  end
  
  
  def welcome
    
  end
  
  def lookbook
    if request.method == "POST"
      session[:lookbook] = params
      redirect_to preview_lookbook_designer_path(params[:id])
    else
      #session[:lookbook] = nil
      @lookbook = Lookbook.find_by_designer_id_and_contest_id(session[:designer_id], params[:id])
      if @lookbook.present?
        @pictures = @lookbook.lookbook_details.where(:doc_type => 1).order("id ASC")
        if @pictures.present?
          @doc_id = @pictures.collect{|doc| doc.document_id}
          if @doc_id.present?
            @doc_path = []
            @doc_id.each do |doc_id|
              doc = Image.find_by_id(doc_id)
              @doc_path << doc.image.url(:medium)
            end
          end
          @doc_id = @doc_id.join(',')
          @doc_path = @doc_path.join(',')
        end
        @links = @lookbook.lookbook_details.where(:doc_type => 2).order("id ASC") 
      end
    end  
  end
  
  def preview_lookbook
    redirect_to lookbook_designer_path(params[:id]) if session[:lookbook].blank?
    #aise session[:lookbook].inspect
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
