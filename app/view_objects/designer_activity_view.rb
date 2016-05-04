class DesignerActivityView

  attr_reader :designer_activity

  delegate :id, :hours, :task, :start_date, :due_date, to: :designer_activity

  def initialize(designer_activity)
    @designer_activity = designer_activity
  end

  def comments
    designer_activity.comments.includes(:author).order(created_at: :desc)
  end

  def contest_id
    designer_activity.time_tracker.contest.id
  end

end
