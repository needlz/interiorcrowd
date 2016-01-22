class ContestShortDetailsForGuest < ContestShortDetails

  def get_days_till_end
    result = super
    result = '0' if contest.response_winner
    result
  end

end
