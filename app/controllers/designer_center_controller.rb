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
    @suggested_contests = Contest.all.includes(:design_category, :design_space)
    @all_contests = Contest.all
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
