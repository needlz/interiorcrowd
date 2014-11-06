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

    params.require(:client).permit(:first_name, :last_name, :email, :address, :name_on_card, :state, :zip, :password)
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
    all_steps = session[:design_categories].present? && session[:space_areas].present? && session[:design_style].present? && session[:design_space].present? && session[:preview].present?
    if all_steps
      params = ActionController::Parameters.new contest: {cd_cat: session[:design_categories][:cat_id].present? ? session[:design_categories][:cat_id].join(",") : '',
                                                          cd_other_cat: session[:design_categories][:other],

                                                          cd_space: session[:space_areas].join(','),

                                                          cd_feminine_scale: session[:design_style][:Feminine],
                                                          cd_elegant_scale: session[:design_style][:elegant],
                                                          cd_traditional_scale: session[:design_style][:traditional],
                                                          cd_muted_scale: session[:design_style][:muted],
                                                          cd_conservative_scale: session[:design_style][:conservative],
                                                          cd_timeless_scale: session[:design_style][:timeless],
                                                          cd_fancy_scale: session[:design_style][:fancy],
                                                          cd_fav_color: session[:design_style][:fav_color],
                                                          cd_refrain_color: session[:design_style][:refrain_color],
                                                          cd_style_ex_images: session[:design_style][:document_id],
                                                          cd_style_links: session[:design_style][:ex_links],

                                                          cd_space_images: session[:design_space][:document_id],
                                                          space_length: session[:design_space][:length],
                                                          space_width: session[:design_space][:width],
                                                          space_height: session[:design_space][:height],
                                                          cd_space_budget: session[:design_space][:f_budget],
                                                          feedback: session[:design_space][:feedback],

                                                          budget_plan: session[:preview][:b_plan],
                                                          project_name: session[:preview][:project_name],
                                                          client_id: user_id
      }

      params.require(:contest).permit(:client_id, :project_name, :budget_plan, :feedback, :cd_space_budget,
                                      :cd_space_images,
                                      :cd_space_flength,
                                      :space_length,
                                      :space_width,
                                      :space_height,
                                      :cd_feminine_scale,
                                      :cd_elegant_scale,
                                      :cd_traditional_scale,
                                      :cd_muted_scale,
                                      :cd_conservative_scale,
                                      :cd_timeless_scale,
                                      :cd_fancy_scale,
                                      :cd_fav_color,
                                      :cd_refrain_color,
                                      :cd_refrain_color,
                                      :cd_style_ex_images,
                                      :cd_style_links,
                                      :cd_space,
                                      :cd_other_cat,
                                      :cd_cat
      )
      if Contest.new(params[:contest]).save()
        session[:design_categories] = nil
        session[:space_areas] = nil
        session[:design_style] = nil
        session[:design_space] = nil
        session[:preview] = nil
      end
    end
  end

end
    
  
  

