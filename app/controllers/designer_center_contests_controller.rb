class DesignerCenterContestsController < ApplicationController
  before_filter :set_designer

  def index
    available_contests = AvailableContestsQuery.new(@designer)
    @invited_contests = contests_list(available_contests.invited)
    @current_contests = contests_list(available_contests.all)
    @suggested_contests = contests_list(available_contests.suggested)
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

  def contests_list(contests)
    ContestsColumns.new(contests.with_associations.includes([:contests_appeals, :preferred_retailers, client: :designer_level]).order(created_at: :desc).uniq)
  end

end
