class DesignerActivitiesGrouper

  attr_reader :groups

  def initialize(activities_views, time_tracker)
    activities_by_week = activities_views.sort_by(&:start_date).reverse.group_by do |activity|
      activity.start_date.at_end_of_week
    end
    @groups = activities_by_week.map { |week, activities_views|
      DesignerActivitiesGroupView.new(group_id: group_id(week),
                                      activities_views: activities_views,
                                      time_tracker: time_tracker,
                                      groups_holder: self,
                                      group_title: group_title(week)
    ) }
  end

  def any?
    groups.present?
  end

  def group_by_activity(activity)
    groups.find { |group| group.activities_views.find { |activity_view| activity_view.designer_activity == activity } }
  end

  private

  def group_id(week)
    week.at_beginning_of_week.to_i
  end

  def group_title(week)
    week.at_beginning_of_week.strftime('%b %d') + ' - ' + week.strftime('%d')
  end

end
