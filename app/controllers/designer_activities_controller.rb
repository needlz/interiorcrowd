class DesignerActivitiesController < ApplicationController

  def create
    begin
      tracker = Contest.find(params[:contest_id]).time_tracker

      activity_form = DesignerActivityForm.new(params)

      activities = activity_form.activities_params.map { |activity_params|
        activity = tracker.designer_activities.create!(designer_activity_params(activity_params))
        comment_attributes = activity_params.try(:[], :comments)
        if comment_attributes.try(:[], :text).present?
          activity.comments.create(comment_attributes.merge(author: current_user))
        end
        activity
      }

      week = activities.first.start_date.at_end_of_week
      week_id = week.at_beginning_of_week.to_i
    rescue StandardError => e
      log_error(e)
      render status: :server_error, json: t('time_tracker.designer.request_send_error')
    else
      activities_views = tracker.designer_activities.map { |activity| DesignerActivityView.new(activity, current_user) }
      groups_holder = DesignerActivitiesGrouper.new(activities_views, tracker)
      groups_titles_html = groups_holder.groups.map { |group|
        { group_id: group.group_id,
          title_html: render_to_string(partial: 'time_tracker/activities_group_title', locals: { group_view: group }) }
      }
      responses = activities.map { |activity|
        group_view = groups_holder.group_by_activity(activity)
        { new_activity_html: render_to_string(partial: 'time_tracker/activity',
                                              locals: { activity_view: DesignerActivityView.new(activity, current_user),
                                                        collapsed: false }),
          id: activity.id,
          group_id: week_id,
          group_header_html: render_to_string(partial: 'time_tracker/group_header',
                                              locals: { group_view: group_view,
                                                        collapsed: false,
                                                        header_only: true }) }
      }
      render status: :ok, json: { activities: responses, groups_titles_html: groups_titles_html }
    end
  end

  def read
    tracker = Contest.find(params[:contest_id]).time_tracker
    activity = tracker.designer_activities.find(params[:id])
    comments = activity.comments.where.not(author_id: current_user.id, author_type: current_user.class.name)
    comments.update_all(read: true)
    render json: { saved: true, activity_id: activity.id }
  end

  private

  def designer_activity_params(activity_params)
    activity_params.permit(:start_date, :due_date, :task, :hours)
  end

end
