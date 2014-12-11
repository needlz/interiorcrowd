class DesignerCenterContestsController < ApplicationController
  before_filter :set_designer
  before_filter :set_navigation

  def index
    @current_contests = Contest.all.includes(:design_category, :design_space)
    @suggested_contests = @current_contests
  end

  def show
    @contest = Contest.find(params[:id])
    @contest_view = ContestView.new(@contest)
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end

  def set_navigation
    @navigation = Navigation::DesignerCenter.new(view_context)
  end
end
