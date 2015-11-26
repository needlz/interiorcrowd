class ReviewerInvitationsController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    invite = InviteReviewer.new(contest: @contest, invitation_attributes: invite_params, view_context: view_context)
    invite.perform
    render json: { url: invite.signed_url, token: invite.invitation.url }
  end

  private

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def invite_params
    params.require(:reviewer_invitation).permit(:username, :email)
  end

end
