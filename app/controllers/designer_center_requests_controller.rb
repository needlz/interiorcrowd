class DesignerCenterRequestsController < ApplicationController
  before_filter :set_designer

  def index
    respond_to do |format|
      format.any(:js, :html) {
        @responses = @designer.requests_by_status(params[:status]).with_design_properties
        @current_responses = @responses
          .map{ |respond| ContestResponseView.new(respond) }
          .sort_by{ |response| response.contest.days_count }
          .reverse
      }
      @navigation = Navigation::DesignerCenter.new(:requests)
    end
  end

  def show
    @request = @designer.contest_requests.find(params[:id])
    @contest = ContestShortDetails.new(@request.contest)
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def edit
    @request = @designer.contest_requests.find(params[:id])
    return redirect_to designer_center_response_path(id: @request.id) if @request.basic_editing_only?
    @navigation = Navigation::DesignerCenter.new(:requests)
    @current_user = current_user
    @request_view = ContestResponseView.new(@request)
  end

  def preview
    @request = @designer.contest_requests.find(params[:id])
    @navigation = Navigation::DesignerCenter.new(:requests)
  end

  def update
    request = ContestRequest.find(params[:id])
    return raise_404 unless request.editable?
    contest_editing = ContestRequestEditing.new({ request: request,
                                                  contest_request_options: params[:contest_request],
                                                  contest_request_attributes: response_params
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
    @contest = Contest.find(params[:contest_id])
    existing_request = @contest.response_of(@designer)
    return redirect_to designer_center_response_path(id: existing_request.id) if existing_request

    @navigation = Navigation::DesignerCenter.new(:requests)
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
                                           need_submit: params[:contest_request][:status] == 'submitted',
                                           comment: params[:comment] }
    )

    request = contest_creation.perform

    respond_to do |format|
      format.html { redirect_to designer_center_response_path(id: request.id) }
    end
  end

  private

  def response_params
    params.require(:contest_request).permit(:feedback, :final_note, :pull_together_note)
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
