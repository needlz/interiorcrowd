class DesignerActivityCreationResult

  attr_reader :creation_result, :view_context, :current_user, :time_tracker, :groups_holder, :user

  def initialize(options)
    @creation_result = options[:creation_result]
    @view_context = options[:view_context]
    @current_user = options[:current_user]
    @time_tracker = options[:time_tracker]
    @user = options[:user]
  end

  def to_hash
    activities_views = time_tracker.designer_activities.map { |activity| DesignerActivityView.new(activity, user) }
    @groups_holder = DesignerActivitiesGrouper.new(activities_views, time_tracker)
    groups_titles_html = groups_holder.groups.map { |group|
      { group_id: group.group_id,
        title_html: view_context.render(partial: 'time_tracker/activities_group_title', locals: { group_view: group,
                                                                                                  collapsed: false }) }
    }

    responses = creation_result.map do |activity_creation_result|
      activity_result(activity_creation_result)
    end
    { activities: responses, groups_titles_html: groups_titles_html, hours_actual: time_tracker.hours_actual - time_tracker.tracked_hours}
  end

  def activity_result(creation_result)
    activity = creation_result[:activity]
    if activity.persisted?
      group_view = groups_holder.group_by_activity(activity)
      { new_activity_html: view_context.render(partial: 'time_tracker/activity',
                                            locals: { activity_view: DesignerActivityView.new(activity, user),
                                                      collapsed: false }),
        id: activity.id,
        group_id: group_view.group_id,
        group_header_html: view_context.render(partial: 'time_tracker/group_header',
                                            locals: { group_view: group_view,
                                                      collapsed: false,
                                                      header_only: true }),
        temporary_id: creation_result[:temporary_id]
      }
    else
      {
        error: activity.errors.messages,
        temporary_id: creation_result[:temporary_id]
      }
    end
  end

end
