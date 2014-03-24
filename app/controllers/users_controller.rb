class UsersController < ApplicationController
  
  # POST /users
  # POST /users.json
  def create
      user_ps = params[:user][:password]
      params[:user][:password] = User.encrypt(params[:user][:password])
      params[:user][:password_confirmation] = User.encrypt(params[:user][:password_confirmation])
      
      params.require(:user).permit(:first_name, :last_name, :email, :password)
      #raise session[:step5].inspect
      @user = User.new(params[:user])
      respond_to do |format|
          if @user.save
            #OscarMailer.student_registration_mail(@student, st_ps, @user).deliver
            #session[:id] = @student.id 
            #session[:role] = User::STUDENT
            #session[:user_id] = @user.id
            create_contests(@user.id)
            format.html { redirect_to root_path}  
            format.json { render json: @user, status: :created, location: @user }
          else
            flash[:error] = @user.errors.full_messages.join("</br>") 
            format.html { render :template => "contests/step6" }
            format.json { render json: @user.errors, status: :unprocessable_entity }
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
                    :cd_space_flength => session[:step4][:f_length],
                    :cd_space_ilength => session[:step4][:i_length],
                    :cd_space_fwidth => session[:step4][:f_width],
                    :cd_space_iwidth => session[:step4][:i_width],
                    :cd_space_fheight => session[:step4][:f_height],
                    :cd_space_iheight => session[:step4][:i_height],
                    :cd_space_budget => session[:step4][:f_budget],
                    :feedback => session[:step4][:feedback],
                    
                    :budget_plan => session[:step5][:b_plan],
                    :project_name => session[:step5][:project_name],
                    :user_id => user_id
                   }
                   
         params.require(:contest).permit(:user_id, :project_name, :budget_plan, :feedback, :cd_space_budget,
                         :cd_space_images, :cd_space_flength, 
                         :cd_space_ilength, 
                         :cd_space_fwidth, 
                         :cd_space_iwidth, 
                         :cd_space_fheight, 
                         :cd_space_iheight,
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
    
  
  

