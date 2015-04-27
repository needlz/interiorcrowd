class DesignerCenterRequestsController < ApplicationController
  before_filter :set_designer

  def index
    respond_to do |format|
      format.any(:js, :html) {
        responses_query = DesignerResponsesQuery.new(@designer)
        @current_responses = ContestResponseView.for_responses(responses_query.current_responses)
        @completed_responses = ContestResponseView.for_responses(responses_query.completed_responses)
      }
      @navigation = Navigation::DesignerCenter.new(:requests)
    end
  end

  def show
    @request = @designer.contest_requests.find(params[:id])
    @request_view = ContestResponseView.new(@request)
    @contest = ContestShortDetails.new(@request.contest)
    @show_page = ConceptBoardPreview.new({
      contest_request: @request,
      preferred_view: params[:view],
      view_context: view_context
    })
    @visible_image_items = @show_page.image_items
    @navigation = Navigation::DesignerCenter.new(:requests)
    set_image_item_views
  end

  def edit
    @request = @designer.contest_requests.find(params[:id])
    return redirect_to designer_center_response_path(id: @request.id) unless @request.details_editable?
    @navigation = Navigation::DesignerCenter.new(:requests)
    @current_user = current_user
    @request_view = ContestResponseView.new(@request)
    @editing_page = ConceptBoardEditing.new({
      contest_request: @request,
      preferred_view: params[:view],
      view_context: view_context
    })
    @visible_image_items = @editing_page.image_items
    set_image_item_views
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
      contest_request_attributes: response_params,
      event_tracker: @event_tracker
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
    @contest_view = ContestView.new(contest_attributes: @contest)
    @contest_short_details = ContestShortDetails.new(@contest)
    @request = ContestRequest.new(contest_id: @contest.id)
  end

  def create
    contest = Contest.current.find_by_id(params[:contest_id])
    return raise_404 unless contest
    contest_creation = ContestRequestCreation.new({ designer: @designer,
                                           contest: contest,
                                           request_params: response_params,
                                           lookbook_params: params[:lookbook],
                                           need_submit: params[:contest_request][:status] == 'submitted' }
    )
    request = contest_creation.perform

    return raise_404 unless request
    respond_to do |format|
      format.html { redirect_to designer_center_response_path(id: request.id) }
    end
  end

  private

  def response_params
    params.permit(contest_request: [:feedback, :final_note, :pull_together_note])[:contest_request]
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

  def set_image_item_views
    @product_items = ImageItemView.for_image_items(@visible_image_items.product_items)
    @similar_styles = ImageItemView.for_image_items(@visible_image_items.similar_styles)
  end
end
