class CreateDesignerActivities < Action

  attr_reader :activity_form, :time_tracker, :result, :user

  def initialize(options)
    @activity_form = options[:activity_form]
    @time_tracker = options[:time_tracker]
    @user = options[:user]
  end

  def perform
    @result = activity_form.activities_params.map do |activity_params|
      activity = DesignerActivity.new(designer_activity_params(activity_params))
      activity.validate
      if activity.hours && (time_tracker.tracked_hours + activity.hours) > time_tracker.hours_actual
        activity.errors.add(:hours, 'Hours spent on tasks can\'t exceed those purchased by client')
      end
      if activity.errors.empty? && activity.save
        comment_attributes = activity_params.try(:[], :comments)
        if activity.persisted? && comment_attributes.try(:[], :text).present?
          activity.comments.create(comment_attributes.merge(author: user))
        end
        time_tracker.designer_activities << activity
        time_tracker.update_attributes(hours_actual: time_tracker.hours_actual - activity.hours)
      end
      {
        temporary_id: activity_params[:temporary_id],
        activity: activity
      }
    end
  end

  def designer_activity_params(activity_params)
    activity_params.permit(:start_date, :due_date, :task, :hours)
  end

end
