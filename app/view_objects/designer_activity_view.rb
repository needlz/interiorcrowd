class DesignerActivityView

  attr_reader :designer_activity, :spectator

  delegate :id, :hours, :task, :start_date, :due_date, to: :designer_activity

  DEFAULT_VALUES = {
    hour: 1,
    task: '',
    comments: {
      text: ''
    }
  }

  def initialize(designer_activity, spectator)
    @designer_activity = designer_activity
    @spectator = spectator
  end

  def comments
    designer_activity.comments.includes(:author).order(created_at: :desc)
  end

  def contest_id
    designer_activity.time_tracker.contest.id
  end

  def has_unread_comments?
    designer_activity.comments.where(read: false).where.not(author_id: spectator.id, author_type: spectator.class.name).exists?
  end

end
