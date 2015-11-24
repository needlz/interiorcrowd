class EndMilestone

  attr_reader :contest

  def initialize(contest)
    raise ArgumentError.new("can not be applied to contest with '#{ contest.status }' status") unless contest.send("#{ status }?")
    @contest = contest
  end

end
