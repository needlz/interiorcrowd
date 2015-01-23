class DesignerInvitationsController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    @contest.invite(params[:designer_id])
    render nothing: true
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
end
