class DesignerInvitationsController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    created = correct_attributes? && @contest.designer_invitations.new(designer_id: params[:designer_id]).save
    respond_to do |format|
      format.json { render json: { success: !!created } }
    end
  end

  private

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def check_contest_owner
    return unless check_client
    @client = Client.find(session[:client_id])
    raise_404 unless @contest.client == @client
  end

  def correct_attributes?
    Designer.find_by_id(params[:designer_id]) && @contest.submission?
  end

end
