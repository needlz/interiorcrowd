class ContestsColumns

  attr_reader :contests

  def initialize(contests)
    @contests = contests
    @show_days_left_column = contests.current.present? || contests.incomplete.present?
  end

  def show_days_left_column?
    @show_days_left_column
  end

  def short_details
    return @short_details if @short_details
    @short_details = contests.map { |contest| ContestShortDetails.new(contest) }
  end

end
