class DesignerCenterRequestsController < ApplicationController
  before_filter :set_designer

  def index
    @responds = @designer.contest_requests.includes(contest: [:design_category, :design_space])
    @current_responds = @responds.map{ |respond| ContestRespondView.new(respond) }
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def show
    @request = @designer.contest_requests.find(params[:id])
    @contest = ContestShortDetails.new(@request.contest)
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def update
    request = ContestRequest.find(params[:id])
    request.update_attributes!(respond_params)
    result = {}
    respond_params.each do |attribute, value|
      result[attribute] = { html: render_to_string(partial: "designer_center_requests/show/previews/#{ attribute }",
                                         locals: { request: request }),
                            value: value }
    end
    render json: result
  end

  private

  def respond_params
    params.require(:respond).permit(:feedback)
  end

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
