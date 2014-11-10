class ClientsController < ApplicationController
  before_filter :check_client, only: [:client_center]

  def client_center
    contests = Client.find_by_id(session[:client_id]).contests.pluck(:id)
    @contest_requests = ContestRequest.where("contest_id IN (?)", contests)
  end

  def create
    user_ps = params[:client][:password]
    params[:client][:password] = Client.encrypt(params[:client][:password])
    params[:client][:password_confirmation] = Client.encrypt(params[:client][:password_confirmation])
    params[:client][:designer_level_id] = session[:design_style][:designer_level]

    params.require(:client).permit(:first_name,
                                   :last_name,
                                   :email,
                                   :address,
                                   :name_on_card,
                                   :state,
                                   :zip,
                                   :password,
                                   :designer_level_id)
    @client = Client.new(params[:client])
    respond_to do |format|
      if @client.save
        Mailer.user_registration(@client, user_ps).deliver
        create_contests(@client.id)
        format.html { redirect_to thank_you_contests_path }
        format.json { render json: @client, status: :created, location: @client }
      else
        flash[:error] = @client.errors.full_messages.join("</br>")
        format.html { render template: "contests/account_creation" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def create_contests(user_id)
    all_steps = session[:design_brief].present? && session[:design_style].present? && session[:design_space].present? && session[:preview].present?
    if all_steps
      params = ActionController::Parameters.new contest: {design_category_id: session[:design_brief][:design_category],
                                                          design_space_id: session[:design_brief][:design_area],
                                                          cd_space_images: session[:design_space][:document_id],
                                                          space_length: session[:design_space][:length],
                                                          space_width: session[:design_space][:width],
                                                          space_height: session[:design_space][:height],
                                                          space_budget: session[:design_space][:f_budget],
                                                          feedback: session[:design_space][:feedback],
                                                          budget_plan: session[:preview][:b_plan],
                                                          project_name: session[:preview][:contest_name],
                                                          client_id: user_id
      }

      params = params.require(:contest).permit(:client_id,
                                      :project_name,
                                      :budget_plan,
                                      :feedback,
                                      :space_budget,
                                      :cd_space_images,
                                      :cd_space_flength,
                                      :space_length,
                                      :space_width,
                                      :space_height,
                                      :feminine_appeal_scale,
                                      :elegant_appeal_scale,
                                      :traditional_appeal_scale,
                                      :muted_appeal_scale,
                                      :conservative_appeal_scale,
                                      :timeless_appeal_scale,
                                      :fancy_appeal_scale,
                                      :desirable_colors,
                                      :undesirable_colors,
                                      :cd_style_ex_images,
                                      :cd_style_links,
                                      :design_space_id,
                                      :design_category_id,
      )
      if Contest.new(params).save!
        session[:design_brief] = nil
        session[:design_style] = nil
        session[:design_space] = nil
        session[:preview] = nil
      end
    end
  end

end
    
  
  

