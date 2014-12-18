class DesignerCenterRequestsController < ApplicationController
  before_filter :set_designer

  def index
    @responses = @designer.contest_requests.includes(contest: [:design_category, :design_space])
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
      request.update_attributes!(respond_params)
      request.update_attributes!(status: 'submitted') if params[:contest_request][:status] == 'submitted'
    end
    respond_to do |format|
      format.html { redirect_to designer_center_response_path(id: request.id) }
      format.json do
        render json: changes(request, respond_params)
      end
    end
  end

  def new
    @navigation = Navigation::DesignerCenter.new(:requests)
    @contest = Contest.find(params[:contest_id])
    @contest_view = ContestView.new(@contest)
    @contest_short_details = ContestShortDetails.new(@contest)
    @request = ContestRequest.new
  end

  def create
    contest = Contest.current.find(params[:contest_id])
    request = @designer.contest_requests.new(respond_params)
    request.status = 'submitted' if params[:contest_request][:status] == 'submitted'
    ContestRequest.transaction do
      contest.requests << request

      request.lookbook = Lookbook.new
      request.lookbook.save!

      if params[:lookbook].try(:[], 'picture').try(:[], 'ids').present?
        document_ids = params[:lookbook]['picture']['ids']
        document_ids.each do |doc|
          LookbookDetail.create({lookbook_id: request.lookbook.id,
                                 image_id: doc,
                                 doc_type: LookbookDetail::UPLOADED_PICTURE_TYPE })
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to designer_center_response_path(id: request.id) }
    end
  end

  private

  def respond_params
    params.require(:contest_request).permit(:feedback)
  end

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end

  def changes(request, changed_params)
    result = {}
    changed_params.each do |attribute, value|
      result[attribute] = { html: render_to_string(partial: "/designer_center_requests/show/previews/#{ attribute }",
                                                   locals: { request: request },
                                                   formats: [:html]),
                            value: value }
    end
    result
  end
end
