require 'will_paginate/array'
class ClientsController < ApplicationController
  include MoodboardCollection

  before_filter :set_client, except: [:create]

  def client_center
    redirect_to entries_client_center_index_path
  end

  def entries
    @contest = @client.last_contest
    return redirect_to design_brief_contests_path unless @contest
    if @contest
      setup_moodboard_collection(@contest)
    else
      @contest_requests = [].paginate
    end
    @navigation = Navigation::ClientCenter.new(:entries)
    @current_user = current_user
    @won_contest_request = @contest.response_winner
    if @won_contest_request
      @entries_page = EntriesConceptBoard.new({
          contest_request: @won_contest_request,
          view_context: view_context
      })
      @visible_image_items = @entries_page.image_items.for_view.paginate(per_page: 4, page: params[:page])
      @share_url = public_designs_url(token: @won_contest_request.token)
    end
    render 'clients/client_center/entries'
  end

  def brief
    @contest = @client.last_contest
    @contest_view = ContestView.new(contest_attributes: @contest)
    @navigation = Navigation::ClientCenter.new(:brief)
    render 'clients/client_center/brief'
  end

  def profile
    @navigation = Navigation::ClientCenter.new(:profile)
    render 'clients/client_center/profile'
  end

  def create
    prepare_creation_params
    @client = Client.new(params[:client])
    respond_to do |format|
      if @client.save
        initialize_client
        create_contest

        format.html { redirect_to entries_client_center_index_path({signed_up: true}) }
        format.json { render json: @client, status: :created, location: @client }
      else
        flash[:error] = @client.errors.full_messages.join("</br>")
        format.html { render template: "contests/account_creation" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @client.update_attributes!(client_params)
    render nothing: true
  end

  def pictures_dimension
    @contest = @client.last_contest
    @contest_view = ContestView.new(contest_attributes: @contest)
    @navigation = Navigation::ClientCenter.new(:entries)
    render 'clients/client_center/pictures_dimension'
  end

  private

  def set_client
    check_client
    @client = Client.find_by_id(session[:client_id])
  end

  def prepare_creation_params
    @user_password = params[:client][:password]
    params[:client][:password] = Client.encrypt(@user_password)
    params[:client][:plain_password] = @user_password
    params[:client][:password_confirmation] = Client.encrypt(params[:client][:password_confirmation])
    params[:client][:designer_level_id] = session[:design_style][:designer_level]
    params.require(:client).permit(:email,
                                   :address,
                                   :name_on_card,
                                   :card_type,
                                   :state,
                                   :zip,
                                   :password,
                                   :plain_password,
                                   :designer_level_id)
  end

  def client_params
    params.require(:client).permit(
        :first_name, :last_name, :address, :state, :zip, :card_number, :card_ex_month,
        :card_ex_year, :card_cvc, :email, :city, :card_type, :phone_number, :billing_address,
        :billing_state, :billing_zip, :billing_city)
  end

  def initialize_client
    client_initialization = ClientInitialization.new({
      plain_password: @user_password,
      client: @client
    })
    client_initialization.perform
    session[:client_id] = @client.id
  end

  def create_contest
    contest_creation = ContestCreation.new(@client.id, session) do
      clear_creation_storage
    end
    contest_creation.perform
  end

end
