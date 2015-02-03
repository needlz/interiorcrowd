class ReviewerFeedbacksController < ApplicationController
  include MoodboardCollection

  before_filter :set_contest, :check_invitation

  def create
    feedback_params[:text] = feedback_params[:text].strip
    @invitation.feedbacks.create!(feedback_params)
    redirect_to action: :show, id: params[:id], token: params[:token]
  end

  def show
    cookies[:token] = params[:token]
    setup_moodboard_collection(@contest)
    @feedbacks = @invitation.feedbacks
    render(:layout => "layouts/without_navigation")
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
