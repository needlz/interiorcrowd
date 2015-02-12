class DesignersController < ApplicationController
  before_filter :check_designer, only: [:welcome, :lookbook, :preview_lookbook]
  before_action :set_designer, only: [:show, :edit, :update, :destroy]

  def thank_you
    render
  end 

  def new
    session[:external_links] = nil
    @designer = Designer.new
    @designer_images = nil
  end

  def create
    user_password = params[:designer][:password]
    params[:designer][:password] = Client.encrypt(params[:designer][:password])
    params[:designer][:password_confirmation] = Client.encrypt(params[:designer][:password_confirmation])
    params[:designer][:ex_links] = params[:external_links].try(:reject) { |c| c.empty? }.try(:join, ',')
    session[:external_links] = params[:designer][:ex_links]
    @designer = Designer.new(designer_params)
    respond_to do |format|
      if @designer.save
        session[:external_links] = nil
        session[:designer_id] = @designer.id
        @designer.create_portfolio(params[:portfolio])
        Jobs::Mailer.schedule(:user_registration, [@designer, user_password])
        format.html { redirect_to edit_portfolio_path, notice: 'Designer was successfully created.' }
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

  def welcome
    render
  end
  
  def lookbook
    if request.method == "POST"
      session[:lookbook] = params
      redirect_to preview_lookbook_designer_path(params[:id])
    else
      lookbook_options =
        if session[:lookbook].present?
          session[:lookbook]
        else
          designer = Designer.find(session[:designer_id])
          Contest.find(params[:id]).response_of(designer).try(:lookbook)
        end
      @lookbook_view = DesignerLookbook.new(lookbook_options)
    end  
  end
  
  def preview_lookbook
    redirect_to lookbook_designer_path(params[:id]) if session[:lookbook].blank?
    @lookbook_view = DesignerLookbook.new(session[:lookbook])
  end

  private

  def set_designer
    @designer = Designer.find(params[:id]) if params[:id].present?
  end

  def designer_params
    params.require(:designer).permit(:first_name, :email, :last_name, :password,
                                     :password_confirmation, :zip, :portfolio, :external_links)
  end
end
