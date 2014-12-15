class DesignerCenterRespondsController < ApplicationController
  before_filter :set_designer

  def index
    @responds = @designer.contest_requests.includes(contest: [:design_category, :design_space])
    @current_responds = @responds.map{ |respond| ContestRespondView.new(respond) }
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def show
    @respond = @designer.contest_requests.find(params[:id])
    @contest = ContestShortDetails.new(@respond.contest)
    @navigation = Navigation::DesignerCenter.new(:index)
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
