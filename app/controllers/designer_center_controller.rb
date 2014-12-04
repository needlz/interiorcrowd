class DesignerCenterController < ApplicationController
  before_filter :set_designer

  def designer_center
    if @designer.has_portfolio?
      redirect_to show_portfolio_path(url: @designer.portfolio_path)
    else
      redirect_to edit_portfolio_path
    end
  end

  private

  def set_designer
    check_designer
    @designer = Designer.where(id: session[:designer_id]).first
  end
end
