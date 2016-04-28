class ContestRequestsController < ApplicationController
  include TextFormatHelper
  before_filter :check_designer, only: [:create, :save_lookbook]
  before_filter :check_client, only: [:answer, :download]
  before_filter :set_request, only: [:answer, :approve_fulfillment, :download, :show]
  before_filter :check_contest_owner, only: [:answer, :download]

  def answer
    replied = @request.reply(params[:answer], current_user.id)
    render json: { answered: replied }
  end

  def approve_fulfillment
    # return if current_user.client?
    approve_fulfillment = ApproveFulfillment.new(@request)
    approve_fulfillment.perform
    render json: { approved: approve_fulfillment.approved }
  end

  def show
    if @request.contest_owner?(current_user)
      @client = current_user
      @show_answer_options = @request.answerable?
      @navigation = Navigation::ClientCenter.new(:entries, contest: @request.contest)
      @setup_viglink = true
      TrackContestRequestVisit.perform(@request)
      @breadcrumbs = Breadcrumbs::Client.new(self).my_contests.contest(@request.contest, true).contest_request(@request)
    elsif !current_user.can_see_contest?(@request.contest, cookies)
      if current_user.client?
        render_404
      else
        redirect_to client_login_sessions_path
      end
    end
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
    raise_404 unless @request.contest_owner?(@client)
  end

  def set_request
    @request = ContestRequest.find(params[:id])
  end

end
