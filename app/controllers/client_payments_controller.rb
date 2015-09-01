class ClientPaymentsController < ApplicationController

  before_filter :set_client

  def create
    begin
      contest = @client.contests.not_payed.find(params[:contest_id])
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end
    apply_promocode(contest)
    do_payment(contest)
  end

  private

  def apply_promocode(contest)
    code = params[:client].try(:[], :promocode)
    ApplyPromocode.new(contest, code).perform
  end

  def do_payment(contest)
    payment = Payment.new(contest)
    begin
      payment.perform
    rescue ArgumentError; end
    if payment.error_message.present?
      flash[:error] = payment.error_message
      redirect_to payment_details_contests_path(id: contest.id)
    else
      redirect_to payment_summary_contests_path(id: contest.id)
    end
  end

end
