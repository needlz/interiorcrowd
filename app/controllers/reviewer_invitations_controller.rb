class ReviewerInvitationsController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    @contest.invite_reviewer(invite_params)
    render nothing: true
  end

  private

  def set_contest
    @contest = Contest.find(params[:reviewer_invitation][:contest_id])
  end

  def invite_params
    params.require(:reviewer_invitation).permit(:username, :email)
  end

end
