class ReviewerInvitationsController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    invitation = @contest.invite_reviewer(invite_params)
    url = show_reviewer_feedbacks_url(id: @contest.id, token: invitation.url)
    Jobs::Mailer.schedule(:invitation_to_leave_a_feedback, [invite_params, url, @client, Settings.app_url])
    render json: { url: url, token: invitation.url }
  end

  private

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def invite_params
    params.require(:reviewer_invitation).permit(:username, :email)
  end

end
