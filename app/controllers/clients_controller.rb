class ClientsController < ApplicationController
  before_filter :check_client, :only => [:client_center]
  # POST /clients
  # POST /clients.json
  def client_center
    contests = Client.find_by_id(session[:client_id]).contests.pluck(:id)
    @contest_requests = ContestRequest.where("contest_id IN (?)", contests)
    
  end
  
  def create
      user_ps = params[:client][:password]
      params[:client][:password] = Client.encrypt(params[:client][:password])
      params[:client][:password_confirmation] = Client.encrypt(params[:client][:password_confirmation])
      
      params.require(:client).permit(:first_name, :last_name, :email, :address, :name_on_card, :state, :zip, :password)
      #raise session[:step5].inspect
      @client = Client.new(params[:client])
      respond_to do |format|
          if @client.save
            ICrowd.user_registration(@client, user_ps).deliver
            #session[:id] = @student.id 
            #session[:role] = Client::STUDENT
            #session[:user_id] = @client.id
            create_contests(@client.id)
            format.html { redirect_to thank_you_contests_path}  
            format.json { render json: @client, status: :created, location: @client }
          else
            flash[:error] = @client.errors.full_messages.join("</br>")
            format.html { render :template => "contests/step6" }
            format.json { render json: @client.errors, status: :unprocessable_entity }
          end
      end
  end
  
  
  def create_contests(user_id)
      all_steps = session[:step1].present? && session[:step2].present? && session[:step3].present? && session[:step4].present? && session[:step5].present?
      if all_steps  
        params = ActionController::Parameters.new contest: {:cd_cat => session[:step1][:cat_id].present? ? session[:step1][:cat_id].join(",") : '',
                    :cd_other_cat => session[:step1][:other],
                    
                    :cd_space => session[:step2].join(','),
                    
                    :cd_feminine_scale => session[:step3][:Feminine],
                    :cd_elegant_scale => session[:step3][:elegant],
                    :cd_traditional_scale => session[:step3][:traditional],
                    :cd_muted_scale => session[:step3][:muted],
                    :cd_conservative_scale => session[:step3][:conservative],
                    :cd_timeless_scale => session[:step3][:timeless],
                    :cd_fancy_scale => session[:step3][:fancy],
                    :cd_fav_color =>  session[:step3][:fav_color],
                    :cd_refrain_color =>  session[:step3][:refrain_color],
                    :cd_refrain_color =>  session[:step3][:refrain_color],
                    :cd_style_ex_images => session[:step3][:document_id],
                    :cd_style_links => session[:step3][:ex_links],
                    
                    :cd_space_images => session[:step4][:document_id],
                    :space_length => session[:step4][:f_length],
                    :space_width => session[:step4][:f_width],
                    :space_height => session[:step4][:f_height],
                    :cd_space_budget => session[:step4][:f_budget],
                    :feedback => session[:step4][:feedback],
                    
                    :budget_plan => session[:step5][:b_plan],
                    :project_name => session[:step5][:project_name],
                    :user_id => user_id
                   }
                   
         params.require(:contest).permit(:user_id, :project_name, :budget_plan, :feedback, :cd_space_budget,
                         :cd_space_images, :cd_space_flength, 
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
                          :cd_fav_color ,
                          :cd_refrain_color ,
                          :cd_refrain_color ,
                          :cd_style_ex_images,
                          :cd_style_links,
                          :cd_space,
                          :cd_other_cat,
                          :cd_cat
                         )         
           if Contest.new(params[:contest]).save()
              session[:step1] = nil
              session[:step2] = nil
              session[:step3] = nil
              session[:step4] = nil
              session[:step5] = nil
          end  
      end  
  end  

end
    
  
  

