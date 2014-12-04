class PortfoliosController < ApplicationController
  before_filter :set_designer, only: [:edit, :create, :update, :new]

  def show
    @designer = Designer.where(portfolio_path: params[:url]).first
    @portfolio_items = @designer.portfolio_pictures
  end

  def edit
    render
  end

  def update
    @designer.update_attributes!(designer_params)
    if @designer.portfolio_published
      redirect_to show_portfolio_path(url: @designer.portfolio_path)
    else
      redirect_to edit_portfolio_path
    end
  end

  private

  def set_designer
    check_designer
    @designer = Designer.find(session[:designer_id])
  end

  def designer_params
    params.require(:designer)
  end
end
