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
    if activity_or_params
      if activity_or_params.kind_of?(DesignerActivity)
        @activity = activity_or_params
      else
        @params = ActionController::Parameters.new(activity_or_params)
        @params[:designer_activity][:start_date] = Date.strptime(params[:designer_activity][:start_date], "%m/%d/%Y")
        @params[:designer_activity][:due_date] = Date.strptime(params[:designer_activity][:due_date], "%m/%d/%Y")
      end
    else
      @activity = DesignerActivity.new(hours: 1)
    end
  end

  def tasks
    [@activity]
  end

  def tasks_attributes=(attributes)
  end

  def self.model_name
    DesignerActivity.model_name
  end

  def activities_params
    params[:designer_activity][:tasks_attributes].map { |id, task_params|
      task_params.merge(start_date: params[:designer_activity][:start_date],
                        due_date: params[:designer_activity][:start_date])
    }
  end

end
