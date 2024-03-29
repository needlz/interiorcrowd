class ClientPaymentsController < ApplicationController

  before_filter :set_client

  def create
    begin
      @contest = @client.contests.not_paid.find_by_id(params[:contest_id])
      unless @contest
        if @already_charged_contest = @client.contests.find(params[:contest_id])
          return redirect_to payment_summary_contests_path
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
      redirect_to payment_details_contests_path
    else
      redirect_to payment_summary_contests_path
    end
  end

  def apply_promocode
    code = params.dig(:client, :promocode)
    if code
      code.strip!
      ApplyPromocode.new(contest, code).perform
    end
  end

  def do_payment
    if params[:credit_card]
      raise('The client already has credit cards') if @client.credit_cards.present?
      add_card = AddCreditCard.new(client: @client, card_attributes: new_credit_card_params, set_as_primary: true)
      add_card.perform
    else
      card = @client.primary_card
      raise ArgumentError.new('Primary card not set') unless card
    end

    if Settings.automatic_payment
      payment = Payment.new(contest)
      payment.perform
    end

    submission = SubmitContest.new(contest)
    if submission.only_brief_pending?
      notify_about_contest_not_live
    end
    submission.try_perform

    client_contest_created_at = { latest_contest_created_at: Time.current }
    client_contest_created_at.merge!(first_contest_created_at: Time.current) if @client.contests.count == 1
    @client.update_attributes!(client_contest_created_at)
    notify_product_owner
    welcome_client
  end

  def agreed_with_terms_of_use
    params[:client_agree] == 'yes'
  end

  def notify_product_owner
    return if @client.notified_owner
    Jobs::Mailer.schedule(:client_registration_info, [@client.id])
    @client.update_attributes!(notified_owner: true)
  end

  def welcome_client
    if !contest.reload.notified_client_contest_not_yet_live
      Jobs::Mailer.schedule(:client_registered, [@client.id])
    end
  end

  def notify_about_contest_not_live
    ActiveRecord::Base.transaction do
      Jobs::Mailer.schedule(:new_client_no_photos, [contest.id])
      contest.update_attributes!(notified_client_contest_not_yet_live: true)
    end
  end

end
