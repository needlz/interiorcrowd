class DesignerCenterContestsController < ApplicationController
  before_filter :set_designer

  def index
    available_contests = AvailableContestsQuery.new(@designer)
    @invited_contests = ContestsColumns.new(available_contests.invited.with_associations)
    @current_contests = ContestsColumns.new(available_contests.all.with_associations)
    @suggested_contests = ContestsColumns.new(available_contests.suggested.with_associations.uniq)
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
