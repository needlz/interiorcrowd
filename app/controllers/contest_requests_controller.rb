class ContestRequestsController < ApplicationController
  include DesignerCenterHelper
  before_filter :check_designer, only: [:create, :save_lookbook]
  before_filter :check_client, only: [:answer, :download]
  before_filter :check_contest_owner, only: [:answer, :download]
  before_filter :set_request, only: [:answer, :approve_fulfillment, :add_comment, :download]

  def create
    @crequest = ContestRequest.new(params[:contest_request])
    if @crequest.save
      flash[:notice] = "Respond created successfully"
      redirect_to contests_path
    else
      flash[:error] = @crequest.errors.full_messages
      render template: "contests/respond"
    end
  end

  def add_comment
    return raise_404 unless current_user.can_comment_contest_request?(@request)
    comment_creation = ConceptBoardCommentCreation.new(@request, params['comment'], current_user)
    comment = comment_creation.perform
    render json: { text: format_comment(comment.text), user_name: current_user.name }
  end

  def answer
    replied = @request.reply(params[:answer], session[:client_id])
    render json: { answered: replied }
  end

  def approve_fulfillment
    approve_fulfillment = ApproveFulfillment.new(@request)
    approve_fulfillment.perform
    render json: { approved: approve_fulfillment.approved }
  end

  def show
    return unless check_client
    @client = Client.find(session[:client_id])
    @request = ContestRequest.find(params[:id])
    @show_answer_options = @request.answerable?
    @navigation = Navigation::ClientCenter.new(:entries)
  end

  def download
    return raise_404 unless current_user.can_download_concept_board?(@request)
    redirect_to @request.download_url
  end

  def design
    @request = ContestRequest.find_by_token(params[:token])
    return raise_404 unless @request
    @product_items = @request.product_items.includes(:image).paginate(per_page: 4, page: params[:page])
    render 'contest_requests/public_design'
  end

  private

  def check_contest_owner
    @client = Client.find(session[:client_id])
    raise_404 unless @client
  end

  def set_request
    @request = ContestRequest.find(params[:id])
  end
end
