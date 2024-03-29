require 'will_paginate/array'
class ClientsController < ApplicationController

  before_filter :set_client, except: [:create, :validate_card, :sign_up_with_facebook, :sign_up_with_email, :unsubscribe, :ssl_sign_up_with_email]

  def client_center
    redirect_to client_center_entries_path
  end

  def concept_boards_page
    @contest = @client.last_contest
    entries_page = EntriesPage.new(
      contest: @contest,
      view: params[:view],
      answer: params[:answer],
      page: params[:page],
      current_user: current_user,
      view_context: view_context
    )
    render json: {
             new_items_html: render_to_string(partial: 'clients/client_center/entries/feedback/feedback_items',
                                              locals: { contest_page: entries_page }),
             show_mobile_pagination: entries_page.show_mobile_pagination?,
             next_page: entries_page.requests_next_page_index }
  end

  def brief
    begin
      @contest = @client.contests.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    if @contest.incomplete?
      return redirect_to ContestCreationWizard.incomplete_step_path(@contest)
    end
    @contest_view = ContestView.new(contest_attributes: @contest)
    @breadcrumbs = Breadcrumbs::Client.new(self).my_contests.contest(@contest).brief(@contest)
    @navigation = "Navigation::ClientCenter::#{ @contest.status.camelize }".constantize.new(:brief, contest: @contest)
    render 'clients/client_center/brief'
  end

  def profile
    @navigation = Navigation::ClientCenter::Base.new(:profile)
    render 'clients/client_center/profile'
  end

  def create
    client_sign_up = ClientIntakeFormSignUp.new(params, session)
    client_creation = ClientCreation.new(client_attributes: client_sign_up.client_attributes)
    client_creation.perform
    contest = create_contest(client_creation.client, true, params[:client][:promocode]) if client_creation.saved
    respond_to_signup(client_creation, contest)
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
    @navigation = "Navigation::ClientCenter::#{ @contest.status.camelize }".constantize.new(:entries)
    render 'clients/client_center/pictures_dimension'
  end

  def validate_card
    card_attributes = { number: params[:card_number],
                        exp_month: params[:card_ex_month],
                        exp_year: params[:card_ex_year],
                        cvc: params[:card_cvc],
                        name: "#{ params[:first_name] } #{ params[:last_name] }",
                        address_line1: params[:billing_address],
                        address_city: params[:billing_city],
                        address_state: params[:billing_state],
                        address_zip: params[:billing_zip],
                        address_country: StripeCustomer::DEFAULT_COUNTRY }
    card_validation = CardValidation.new(card_attributes)
    card_validation.perform
    render json: { valid: card_validation.valid,
                   error: card_validation.error_message }
  end

  def sign_up_with_email
    fast_signup(ClientEmailSignUp)
  end

  def ssl_sign_up_with_email
    fast_signup(ClientEmailSignUp)
  end

  def sign_up_with_facebook
    fast_signup(ClientFacebookSignUp)
  end

  def unsubscribe
    if client = Client.find_by_access_token(params[:signature])
      client.update_attributes!(email_opt_in: false)
      render text: 'You have been unsubscribed'
    else
      raise_404
    end
  end

  private

  def client_update_params
    params.require(:client).permit(
      :first_name, :last_name, :address, :state, :zip, :card_number, :card_ex_month,
      :card_ex_year, :card_cvc, :email, :city, :card_type, :phone_number, :billing_address,
      :billing_state, :billing_zip, :billing_city, :name_on_card)
  end

  def create_contest(client, make_complete, promocode)
    contest_creation = ContestCreation.new(client_id: client.id,
                                           contest_params: session,
                                           promocode: promocode,
                                           make_complete: make_complete)
    contest_creation.on_success do
      clear_creation_storage
    end
    contest_creation.perform
    contest_creation.contest
  end

  def contest_active?
    @contest && !@contest.closed?
  end

  def respond_to_signup(client_creation, contest)
    @client = client_creation.client
    respond_to do |format|
      if client_creation.saved
        session[:client_id] = @client.id

        redirect_path =
          if contest
            contest.completed? ? payment_details_contests_path : ContestCreationWizard.incomplete_step_path(contest)
          else
            client_center_entries_path(signed_up: true)
          end

        format.html { redirect_to redirect_path }
        format.json { render json: @client, status: :created, location: @client }
      else
        error_msg = @client.errors.full_messages.join('<br>')
        format.html do
          flash[:error] = error_msg
          render template: 'contests/account_creation'
        end
        format.json { render json: { error: error_msg }, status: :unprocessable_entity }
      end
    end
  end

  def fast_signup(signup_class)
    params[:client] = {} unless params[:client]
    sign_up = signup_class.new(params)
    client_creation = ClientCreation.new(client_attributes: sign_up.client_attributes,
                                         send_welcome_email: true)
    client_creation.perform
    contest = create_contest(client_creation.client, false, nil) if client_creation.saved
    respond_to_signup(client_creation, contest)
  end

end
