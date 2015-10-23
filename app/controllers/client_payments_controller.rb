class ClientPaymentsController < ApplicationController

  before_filter :set_client

  def create
    begin
      @contest = @client.contests.not_payed.find_by_id(params[:contest_id])
      unless @contest
        if @already_charged_contest = @client.contests.find(params[:contest_id])
          return redirect_to payment_summary_contests_path(id: @already_charged_contest.id)
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    charge
  end

  private

  attr_reader :contest

  def charge
    begin
      raise('To proceed, you need to agree to the Terms of use') unless agreed_with_terms_of_use
      ActiveRecord::Base.transaction do
        apply_promocode
        do_payment
      end
    rescue StandardError => e
      log_error(e)
      flash[:error] = e.message
      redirect_to payment_details_contests_path(id: contest.id)
    else
      redirect_to payment_summary_contests_path(id: contest.id)
    end
  end

  def apply_promocode
    code = params[:client].try(:[], :promocode)
    ApplyPromocode.new(contest, code).perform
  end

  def do_payment
    if params[:credit_card]
      raise('The client already has credit cards') if @client.credit_cards.present?
      add_card = AddCreditCard.new(client: @client, card_attributes: new_credit_card_params, set_as_primary: true)
      add_card.perform
    end

    if Settings.payment_enabled
      payment = Payment.new(contest)
      payment.perform
    end

    client_contest_created_at = { latest_contest_created_at: Time.current }
    client_contest_created_at.merge!(first_contest_created_at: Time.current) if @client.contests.count == 1
    @client.update_attributes!(client_contest_created_at)
  end

  def agreed_with_terms_of_use
    params[:client_agree] == 'yes'
  end

end
