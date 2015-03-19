class AvailableContestsQuery

  def initialize(designer)
    @designer = designer
  end

  def all
    Contest.current.all
  end

  def invited
    designer.invited_contests.current.all
  end

  private

  attr_reader :designer

end
