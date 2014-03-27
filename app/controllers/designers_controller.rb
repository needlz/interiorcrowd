class DesignersController < ApplicationController
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
    @designer = Designer.new
    @designer_images = nil
  end

  # GET /designers/1/edit
  def edit
  end

  # POST /designers
  # POST /designers.json
  def create
    user_ps = params[:designer][:password]
    params[:designer][:password] = User.encrypt(params[:designer][:password])
    params[:designer][:password_confirmation] = User.encrypt(params[:designer][:password_confirmation])
    
    @designer = Designer.new(designer_params)
    respond_to do |format|
      if @designer.save
        ICrowd.designer_registration(@designer, user_ps).deliver
        format.html { redirect_to thank_you_designer_path(@designer), notice: 'Designer was successfully created.' }
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
