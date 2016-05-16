class EditTimeTrackerPolicy < Policy

  def self.for_designer(designer)
    new(designer)
  end

  def initialize(client)
    super
    @designer = client
  end

  def edit(time_tracker)
    permissions << time_tracker.contest.response_winner.designer_id == designer.id
    self
  end

  private

  attr_reader :designer

end
