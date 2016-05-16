class DesignerActivitiesGroupView

  attr_reader :time_tracker, :groups_holder, :group_id, :group_title
  attr_accessor :activities_views

  def initialize(options)
    self.activities_views = options[:activities_views]
    @time_tracker = options[:time_tracker]
    @groups_holder = options[:groups_holder]
    @group_id = options[:group_id]
    @group_title = options[:group_title]
  end

  def hours_left
    time_tracker.hours_actual
  end

  private

  def hours_sum
    activities_views.sum(&:hours)
  end

  def index
    groups_holder.groups.index(self)
  end

  def previous_group_hours_left
    return time_tracker.hours_actual if groups_holder.groups.last == self
    groups_holder.groups[index + 1].hours_left
  end

end
