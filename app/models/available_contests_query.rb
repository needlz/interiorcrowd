class AvailableContestsQuery

  def initialize(designer)
    @designer = designer
  end

  def all
    Contest.current.all
  end

  def all_visible
    return all if designer.can_view_test_pages?
    Contest.current.includes(:client).where(clients: {roles_mask: nil})
  end

  def invited
    designer.invited_contests.current.all
  end

  private

  attr_reader :designer

end
