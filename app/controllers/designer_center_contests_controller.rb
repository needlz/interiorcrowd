class DesignerCenterContestsController < ApplicationController
  before_filter :set_designer

  def index
    contests = Contest.all.includes(:design_category, :design_space)
    @current_contests = contests.map { |contest| ContestShortDetails.new(contest) }
    @suggested_contests = @current_contests
    @navigation = Navigation::DesignerCenter.new(:contests)
  end

  def show
    @contest = Contest.find(params[:id])
    @contest_view = ContestView.new(@contest)
    @navigation = Navigation::DesignerCenter.new(:contests)
  end

  def responds
    responds = @designer.contest_requests.includes(contest: [:design_category, :design_space])
    @current_responds = responds.map{ |respond| ContestRespondView.new(respond) }
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
