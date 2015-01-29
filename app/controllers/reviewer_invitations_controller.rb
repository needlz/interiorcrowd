class ReviewerInvitationsController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    invitation = @contest.invite_reviewer(invite_params)
    render json: { url: show_reviewer_feedbacks_url(id: @contest.id, token: invitation.url), token: invitation.url }
  end

  private

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def invite_params
    params.require(:reviewer_invitation).permit(:username, :email)
  end

end
