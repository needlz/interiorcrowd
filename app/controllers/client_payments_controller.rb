class ClientPaymentsController < ApplicationController

  before_filter :set_client

  def create
    begin
      @contest = @client.contests.not_payed.find_by_id(params[:contest_id])
      unless contest
        if @already_charged_contest = client.contests.find(params[:contest_id])
          return redirect_to payment_summary_contests_path(id: @already_charged_contest.id)
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    charge
  end

  private

  attr_reader :contest, :client

  def charge
    begin
      checkout = ClientCheckout.new(contest: contest,
                                    agreed_with_terms_of_use: params[:client_agree] == 'yes',
                                    promocode: params[:client].try(:[], :promocode),
                                    client: client,
                                    new_credit_card_attributes: params[:credit_card])
      checkout.perform
    rescue Stripe::StripeError, ClientCheckout::CheckoutError => e
      log_error(e)
      flash[:error] = e.message
      redirect_to payment_details_contests_path(id: contest.id)
    else
      redirect_to payment_summary_contests_path(id: contest.id)
    end
  end

end
