class DesignerCenterRequestsController < ApplicationController
  before_filter :set_designer

  def index
    @responses = @designer.contest_requests.active.includes(contest: [:design_category, :design_space])
    @current_responses = @responses.map{ |respond| ContestResponseView.new(respond) }
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def show
    @request = @designer.contest_requests.find(params[:id])
    @contest = ContestShortDetails.new(@request.contest)
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def update
    request = ContestRequest.find(params[:id])
    ContestRequest.transaction do
      request.update_attributes!(response_params)
      request.submit! if params[:contest_request][:status] == 'submitted'
    end
    respond_to do |format|
      format.html { redirect_to designer_center_response_path(id: request.id) }
      format.json do
        render json: format_changed_attributes(response_params)
      end
    end
  end

  def new
    @navigation = Navigation::DesignerCenter.new(:requests)
    contest = Contest.find(params[:contest_id])
    @contest_view = ContestView.new(contest)
    @contest_short_details = ContestShortDetails.new(contest)
    @request = ContestRequest.new(contest_id: contest.id)
  end

  def create
    contest = Contest.current.find(params[:contest_id])
    contest_creation = ContestRequestCreation.new({ designer: @designer,
                                           contest: contest,
                                           request_params: response_params,
                                           lookbook_params: params[:lookbook],
                                           need_submit: params[:contest_request][:status] == 'submitted' }
    )
    request = contest_creation.perform

    respond_to do |format|
      format.html { redirect_to designer_center_response_path(id: request.id) }
    end
  end

  private

  def response_params
    params.require(:contest_request).permit(:feedback)
  end

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end

  def format_changed_attributes(changed_params)
    result = {}
    changed_params.each do |attribute, value|
      result[attribute] = { value: value }
    end
    result
  end
end
