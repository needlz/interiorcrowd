class DesignerCenterContestsController < ApplicationController
  before_filter :set_designer
  before_filter :set_navigation

  def index
    @current_contests = Contest.all.includes(:design_category, :design_space)
    @suggested_contests = @current_contests
    @navigation.active_tab = :contests
  end

  def show
    @contest = Contest.find(params[:id])
    @contest_view = ContestView.new(@contest)
    @navigation.active_tab = :contests
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end

  def set_navigation
    @navigation = Navigation::DesignerCenter.new
  end
end
