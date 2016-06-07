class DesignerActivityForm

  include ActiveModel::Model

  def self.activity_attributes
    DesignerActivity.column_names + DesignerActivity.reflections.keys
  end

  activity_attributes.each do |attr|
    delegate attr.to_sym, "#{ attr }=".to_sym, to: :activity
  end

  attr_reader :activity, :params

  def initialize(activity_or_params = nil)
    if activity_or_params && activity_or_params.kind_of?(DesignerActivity)
      @activity = activity_or_params
    elsif activity_or_params
      @params = ActionController::Parameters.new(activity_or_params)
      begin
        @params[:designer_activity][:start_date] = Date.strptime(params[:designer_activity][:start_date], "%m/%d/%Y")
      rescue ArgumentError
      end
      begin
        @params[:designer_activity][:due_date] = Date.strptime(params[:designer_activity][:due_date], "%m/%d/%Y")
      rescue ArgumentError
      end
    else
      @activity = DesignerActivity.new(hours: 1)
    end
  end

  def tasks
    [@activity]
  end

  def self.model_name
    DesignerActivity.model_name
  end

  def activities_params
    params[:designer_activity][:tasks_attributes].map { |id, task_params|
      task_params.merge(start_date: params[:designer_activity][:start_date],
                        due_date: params[:designer_activity][:due_date],
                        temporary_id: id)
    }
  end

end
