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
      contest_options = complete_contest_options(Contest.options_from_hash(session), user_id)
      contest_attributes = contest_options.require(:contest).permit(
        :client_id,
        :project_name,
        :budget_plan,
        :feedback,
        :space_budget,
        :cd_space_flength,
        :space_length,
        :space_width,
        :space_height,
        :desirable_colors,
        :undesirable_colors,
        :cd_style_links,
        :design_space_id,
        :design_category_id,
      )
      contest = Contest.new(contest_attributes)
      contest.transaction do
        if contest.save!
          contest_associations = contest_options[:contest_associations]
          contest.add_appeals(contest_options[:contest])
          contest.add_external_examples(contest_associations[:example_links])
          contest.add_space_images(contest_associations[:space_image_ids])
          contest.add_example_images(contest_associations[:liked_example_ids])
          clear_session
        end
      end
    end
  end

  def clear_session
    session[:design_brief] = nil
    session[:design_style] = nil
    session[:design_space] = nil
    session[:preview] = nil
  end

  def complete_contest_options(basic_contest_options, user_id)
    ActionController::Parameters.new(
      contest: basic_contest_options[:contest].merge(client_id: user_id),
      contest_associations: basic_contest_options[:contest_associations]
    )
  end

end
    
  
  

