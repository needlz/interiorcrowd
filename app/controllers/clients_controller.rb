require 'will_paginate/array'
class ClientsController < ApplicationController
  include MoodboardCollection

  before_filter :set_client, except: [:create]

  def client_center
    redirect_to entries_client_center_index_path
  end

  def entries
    @contest = @client.last_contest
    return redirect_to design_brief_contests_path unless contest_active?
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
          view_context: view_context,
          preferred_view: params[:view]
      })
      @visible_image_items = @entries_page.image_items.paginate(per_page: 4, page: params[:page])
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
    client_params = prepare_creation_params
    @client = Client.new(client_params)
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
    client_updater = ClientUpdater.new(
        client: @client,
        client_attributes: (client_update_params if params[:client]),
        password_options: params[:password]
    )
    Client.transaction do
      client_updater.perform
    end
    if params[:attribute].present?
      render partial: "clients/client_center/profile/preview/#{ params[:attribute] }", locals: { client: @client }
    else
      render nothing: true
    end
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
    params.require(:client).permit(
        :first_name, :last_name, :address, :state, :zip, :card_number, :card_ex_month,
        :card_ex_year, :card_cvc, :email, :city, :card_type, :phone_number, :billing_address,
        :billing_state, :billing_zip, :billing_city, :password, :plain_password, :password_confirmation,
        :designer_level_id, :name_on_card
    )
  end

  def client_update_params
    params.require(:client).permit(
        :first_name, :last_name, :address, :state, :zip, :card_number, :card_ex_month,
        :card_ex_year, :card_cvc, :email, :city, :card_type, :phone_number, :billing_address,
        :billing_state, :billing_zip, :billing_city, :name_on_card)
  end

  def initialize_client
    client_initialization = ClientInitialization.new({
      plain_password: @user_password,
      client: @client,
      promocode: params[:client][:promocode]
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

  def contest_active?
    @contest && !@contest.closed?
  end

end
