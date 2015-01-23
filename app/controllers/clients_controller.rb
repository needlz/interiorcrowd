require 'will_paginate/array'
class ClientsController < ApplicationController
  before_filter :set_client, except: [:create]

  def client_center
    if @client.last_contest.try(:requests).present?
      redirect_to entries_client_center_index_path
    else
      redirect_to brief_client_center_index_path
    end
  end

  def entries
    @contest = @client.last_contest
    if @contest
      @contest_view = ContestView.new(@contest)
      requests = @contest.requests.published.includes(:designer, :lookbook)
      @contest_requests = requests.by_page(params[:page])
      invitable_designers = Designer.includes(portfolio: [:personal_picture]).all
      @invitable_designer_views = invitable_designers.map { |designer| DesignerView.new(designer) }
    else
      @contest_requests = [].paginate
    end
    @navigation = Navigation::ClientCenter.new(:entries)
    render 'clients/client_center/entries'
  end

  def brief
    @contest = @client.last_contest
    @contest_view = ContestView.new(@contest)
    @navigation = Navigation::ClientCenter.new(:brief)
    render 'clients/client_center/brief'
  end

  def profile
    @navigation = Navigation::ClientCenter.new(:profile)
    render 'clients/client_center/profile'
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
                                   :card_type,
                                   :state,
                                   :zip,
                                   :password,
                                   :designer_level_id)
    @client = Client.new(params[:client])
    respond_to do |format|
      if @client.save
        Mailer.user_registration(@client, user_ps).deliver
        session[:client_id] = @client.id
        contest = create_contest(@client.id)
        format.html { redirect_to additional_details_contest_path(id: contest.id) }
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
    redirect_to profile_client_center_index_path
  end

  def update_profile
    @client.update_attributes!(client_params)
    render nothing: true
  end

  private

  def create_contest(user_id)
    contest_options = ContestOptions.new(session.to_hash.merge(client_id: user_id))
    raise ArgumentError unless contest_options.required_present?
    contest = Contest.create_from_options(contest_options)
    clear_session
    contest
  end

  def clear_session
    session[:design_brief] = nil
    session[:design_style] = nil
    session[:design_space] = nil
    session[:preview] = nil
  end

  def set_client
    check_client
    @client = Client.find_by_id(session[:client_id])
  end

  def client_params
    params.require(:client).permit(:first_name, :last_name, :address, :state, :zip, :card_number, :card_ex_month,
                                   :card_ex_year, :card_cvc, :email, :city, :card_type)
  end

end
