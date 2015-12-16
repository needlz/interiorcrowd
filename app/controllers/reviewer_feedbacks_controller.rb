class ReviewerFeedbacksController < ApplicationController

  before_filter :set_contest, :check_invitation

  def create
    feedback_params[:text] = feedback_params[:text].strip
    feedback = @invitation.feedbacks.create!(feedback_params)
    redirect_to action: :show, id: params[:id], feedback_id: feedback.id, token: params[:token]
  end

  def show
    @feedback = ReviewerFeedback.find_by_id(params[:feedback_id])
    cookies[:reviewer_token] = params[:token]
    @feedback_page = ContestPage.new(contest: @contest)
    @feedbacks = @invitation.feedbacks
    render(layout: 'layouts/without_navigation')
  end

  private

  def set_contest
    @contest = Contest.find(params[:id])
  end

  def check_invitation
    @invitation = @contest.reviewer_invitations.find_by_url(params[:token])
    raise_404 unless @invitation
  end

  def feedback_params
    params.require(:reviewer_feedback).permit(:text)
  end

end
