class DesignerActivityForm

  include ActiveModel::Model

  def self.activity_attributes
    DesignerActivity.column_names + DesignerActivity.reflections.keys
  end

  activity_attributes.each do |attr|
    delegate attr.to_sym, "#{ attr }=".to_sym, to: :activity
  end

  attr_reader :activity

  def initialize(activity_or_params = nil)
    if activity_or_params
      if activity_or_params.kind_of?(DesignerActivity)
        @activity = activity_or_params
      else
        @params = ActionController::Parameters.new(activity_or_params)
        @params[:designer_activity][:start_date] = Date.strptime(@params[:designer_activity][:start_date], "%m/%d/%Y")
        @params[:designer_activity][:due_date] = Date.strptime(@params[:designer_activity][:due_date], "%m/%d/%Y")
      end
    else
      @activity = DesignerActivity.new(hours: 1)
    end
  end

  def activity_comment_attributes
    @params[:designer_activity].try(:comments)
  end

  def self.model_name
    DesignerActivity.model_name
  end

  def activity_attributes
    @params.require(:designer_activity).permit(*self.class.activity_attributes)
  end

end
