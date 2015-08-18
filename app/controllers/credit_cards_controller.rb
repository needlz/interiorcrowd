class CreditCardsController < ApplicationController
  before_filter :set_client

  def index
    available_contests = AvailableContestsQuery.new(@designer)
    @invited_contests = available_contests.invited.with_associations.map { |contest| ContestShortDetails.new(contest) }
    @current_contests = available_contests.all.includes(:design_space, :client).map { |contest| ContestShortDetails.new(contest) }
    @suggested_contests = @current_contests
    @navigation = Navigation::DesignerCenter.new(:contests)
  end

  def show
    @contest = Contest.find(params[:id])
    @contest_view = ContestView.new(contest_attributes: @contest, allow_download_all_photo: true)
    @show_winner_selected_warning = @contest.response_winner && !@contest.response_of(@designer)
    @navigation = Navigation::DesignerCenter.new(:contests)
  end

  def set_as_primary
    current_user.primary_card = CreditCard.find params[:id]
    if current_user.save
      render json: nil, status: :ok
    else
      render json: current_user.errors.full_messages, status: :not_found
    end
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
