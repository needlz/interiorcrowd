class TimeTrackerView

  delegate :hours_actual, :hours_suggested, :contest, :price_per_hour, to: :time_tracker

  def initialize(time_tracker, hours_to_buy = nil)
    @time_tracker = time_tracker
    @hours_to_buy = hours_to_buy
  end

  def suggested_hours?
    hours_suggested > 0
  end

  def hours_actual?
    hours_actual > 0
  end

  def actual_hours?
    hours_actual > 0
  end

  def total_price
    ( price_per_hour * hours_to_buy ) || nil
  end

  def attachments
    time_tracker.attachments.order(:created_at)
  end

  def attachments?
    time_tracker.attachments.present?
  end

  attr_reader :time_tracker, :hours_to_buy

end
