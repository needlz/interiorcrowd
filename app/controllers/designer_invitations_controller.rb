class DesignerInvitationsController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    @invitation = @contest.designer_invitations.new(designer_id: params[:designer_id])
    respond_to do |format|
      format.json { render json: { success: @invitation.save } }
    end
  end

  private

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def check_contest_owner
    return unless check_client
    p @contest.client == @client
    raise_404 if @contest.client == @client
  end

end
