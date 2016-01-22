class DesignerCenterContestsController < ApplicationController
  before_filter :set_designer

  def index
    available_contests = AvailableContestsQuery.new(@designer)
    @invited_contests = available_contests.invited.with_associations.map { |contest| ContestShortDetails.new(contest) }
    @current_contests = available_contests.all.with_associations.map { |contest| ContestShortDetails.new(contest) }
    @suggested_contests = available_contests.suggested.with_associations.uniq.map { |contest| ContestShortDetails.new(contest) }
    @navigation = Navigation::DesignerCenter.new(:contests)
  end

  def show
    @contest = Contest.find(params[:id])
    @contest_view = ContestView.new(contest_attributes: @contest, allow_download_all_photo: true)
    set_contest_short_details
    @show_winner_selected_warning = @contest.response_winner && !@contest.response_of(@designer)
    @navigation = Navigation::DesignerCenter.new(:contests)
  end

  private

  def set_contest_short_details
    short_details_class = @contest.response_winner.try(:designer) == @designer ? ContestShortDetails : ContestShortDetailsForGuest
    @contest_short_details = short_details_class.new(@contest)
  end

end
