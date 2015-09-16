class DesignersController < ApplicationController
  before_filter :check_designer, only: [:welcome]
  before_action :set_designer, only: [:show, :edit, :update, :destroy]

  def new
    session[:external_links] = nil
    @designer = Designer.new
    @designer_images = nil
  end

  def create
    user_password = params[:designer][:password]
    params[:designer][:password] = Client.encrypt(user_password)
    params[:designer][:plain_password] = user_password
    params[:designer][:password_confirmation] = Client.encrypt(params[:designer][:password_confirmation])
    params[:designer][:ex_links] = params[:external_links].try(:reject) { |c| c.empty? }.try(:join, ',')
    session[:external_links] = params[:designer][:ex_links]
    @designer = Designer.new(designer_params)
    respond_to do |format|
      if @designer.save
        session[:external_links] = nil
        session[:designer_id] = @designer.id
        DesignerInitialization.new({
          plain_password: user_password,
          portfolio_params: params[:portfolio],
          designer: @designer
        }).perform
        format.html { redirect_to edit_portfolio_path, notice: 'Designer was successfully created.' }
        format.json { render action: 'show', status: :created, location: @designer }
      else
        @designer_images = params[:designer_image]
        format.html do
          flash[:error] = @designer.errors.full_messages.join("</br>")
          render action: 'new'
        end
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

  private

  def set_designer
    @designer = Designer.find(params[:id]) if params[:id].present?
  end

  def designer_params
    params.require(:designer).permit(:first_name, :email, :last_name, :password, :plain_password, :address, :city,
                                     :password_confirmation, :zip, :portfolio, :external_links, :state, :phone_number)
  end
end
