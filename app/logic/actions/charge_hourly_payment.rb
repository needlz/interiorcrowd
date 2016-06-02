class ChargeHourlyPayment
  DEFAULT_CURRENCY = 'USD'

  attr_reader :hourly_payment

  def initialize(contest, hours_amount)
    @contest = contest
    @client = contest.client
    @time_tracker = contest.time_tracker
    @hours = hours_amount
  end

  def perform
    StripeCustomer.fill_client_info(client)

    @credit_card = client.primary_card
    raise ArgumentError.new('Primary card not set') unless credit_card

    @price = Settings.hour_with_designer_price.to_i * 100

    @total_price = @price * hours

    initialize_payment_record
    begin
      hourly_payment.with_lock do
        ActiveRecord::Base.transaction do
          perform_stripe_charge
          finalize_payment_record
          track_actual_hours
          notify_designer
        end
      end
    rescue StandardError => e
      hourly_payment.update_attributes!(payment_status: 'failed',
                                        last_error: e.message + "\n" + e.backtrace.join("\n"))
      raise
    end
  end

  def initialize_payment_record
    attributes = { payment_status: 'pending',
                   client_id: client.id,
                   time_tracker_id: time_tracker.id,
                   hours_count: hours,
                   total_price_in_cents: total_price,
                   credit_card_id: credit_card.id }

    @hourly_payment = HourlyPayment.create!(attributes)
  end

  private

  attr_reader :contest, :client, :time_tracker, :charge, :price, :total_price, :hours, :credit_card, :hourly_payment

  def perform_stripe_charge
    if price <= 0
      @charge = Hashie::Mash.new(id: Payment::ZERO_PRICE_PLACEHOLDER)
    else
      customer = StripeCustomer.new(client)
      amount = Money.new(total_price, DEFAULT_CURRENCY)
      description = "hourly charge for client with id #{ client.id }"
      @charge = customer.charge(money: amount,
                                description: description,
                                card_id: credit_card.stripe_id)
    end
  end

  def finalize_payment_record
    hourly_payment.update_attributes!(payment_status: 'completed',
                                      stripe_charge_id: charge.id,
                                      last_error: nil)
  end

  def track_actual_hours
    time_tracker.update_attributes(hours_actual: hours + time_tracker.hours_actual,
                                   hours_suggested: 0)
  end

  def notify_designer
    contest_request = contest.response_winner
    Jobs::Mailer.schedule(:client_bought_hours_start_designing, [contest_request.id])
    designer = contest_request.designer
    designer.user_notifications << DesignerTimeTrackerNotification.create!(contest_id: contest.id,
                                                                           contest_request_id: contest_request.id)
  end

end
