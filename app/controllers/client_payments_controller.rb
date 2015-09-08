class ClientPaymentsController < ApplicationController

  before_filter :set_client

  def create
    begin
      contest = @client.contests.not_payed.find(params[:contest_id])
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    begin
      ActiveRecord::Base.transaction do
        apply_promocode(contest)
        do_payment(contest)
      end
    rescue StandardError => e
      log_error(e)
      flash[:error] = e.message
      redirect_to payment_details_contests_path(id: contest.id)
    else
      redirect_to payment_summary_contests_path(id: contest.id)
    end
  end

  private

  def apply_promocode(contest)
    code = params[:client].try(:[], :promocode)
    ApplyPromocode.new(contest, code).perform
  end

  def do_payment(contest)
    payment = Payment.new(contest)
    payment.perform
  end

end
