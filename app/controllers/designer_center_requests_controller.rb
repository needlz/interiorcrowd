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
    @image_id = @request.lookbook.try(:lookbook_details).try(:last).try(:image_id)
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def edit
    @request = @designer.contest_requests.find(params[:id])
    @comments = @request.comments
    @navigation = Navigation::DesignerCenter.new(:requests)
    @current_user = current_user
  end

  def preview
    @request = @designer.contest_requests.find(params[:id])
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def update
    request = ContestRequest.find(params[:id])
    contest_editing = ContestRequestEditing.new({  request: request,
                                                    contest_request: params['contest_request']
                                                 })
    contest_editing.perform

    respond_to do |format|
      format.html { redirect_to designer_center_response_path(id: request.id) }
      format.json do
        render json: format_changed_attributes(response_params)
      end
      format.js {render nothing: true}
    end
  end

  def new
    @navigation = Navigation::DesignerCenter.new(:requests)
    @contest = Contest.find(params[:contest_id])
    @contest_view = ContestView.new(@contest)
    @contest_short_details = ContestShortDetails.new(@contest)
    @request = ContestRequest.new(contest_id: @contest.id)
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
