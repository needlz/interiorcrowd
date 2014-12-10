class DesignerCenterController < ApplicationController
  before_filter :set_designer

  def designer_center
    if @designer.portfolio
      redirect_to edit_portfolio_path
    else
      redirect_to new_portfolio_path
    end
  end

  def contests_index
    @current_contests = Contest.all.includes(:design_category, :design_space)
    @suggested_contests = @current_contests
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
