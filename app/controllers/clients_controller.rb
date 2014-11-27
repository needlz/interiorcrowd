require 'will_paginate/array'
class ClientsController < ApplicationController
  before_filter :check_client, only: [:client_center, :entries, :brief, :profile, :edit_attribute]
  before_filter :set_client, only: [:client_center, :entries, :brief, :profile, :edit_attribute]

  def client_center
    if @client.last_contest.try(:contest_requests).present?
      redirect_to entries_client_center_index_path
    else
      redirect_to brief_client_center_index_path
    end
  end

  def entries
    contest = @client.last_contest
    if contest
      requests = contest.contest_requests.includes(:designer, :lookbook)
      @contest_requests = requests.by_page(params[:page])
    else
      @contest_requests = [].paginate
    end
    render 'clients/client_center/entries'
  end

  def brief
    @contest = @client.last_contest
    @contest_view = ContestView.new(@contest)
    render 'clients/client_center/brief'
  end

  def profile
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

  def edit_attribute
    attribute = params[:attribute]
    render partial: "clients/client_center/profile/forms/#{ attribute }"
  end

  private

  def create_contests(user_id)
    contest_options = ContestOptions.new(session.to_hash.merge(client_id: user_id))
    return unless contest_options.required_present?
    clear_session if Contest.create_from_options(contest_options)
  end

  def clear_session
    session[:design_brief] = nil
    session[:design_style] = nil
    session[:design_space] = nil
    session[:preview] = nil
  end

  def set_client
    @client = Client.find_by_id(session[:client_id])
  end

end
