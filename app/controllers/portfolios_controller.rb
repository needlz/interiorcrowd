class PortfoliosController < ApplicationController
  before_filter :set_designer, only: [:edit, :create, :update, :new]
  before_filter :set_portfolio, only: [:edit, :update, :new]

  def show
    @portfolio = Portfolio.find_by_path(params[:url])
    render_404 unless @portfolio
  end

  def edit
    render
  end

  def new
    return redirect_to edit_portfolio_path if @portfolio
  end

  def update
    Portfolio.transaction do
      @portfolio.update_attributes!(portfolio_params)
      update_potfolio_pictures(@portfolio, params[:portfolio])
      redirect_after_updated(@portfolio)
    end
  end

  def create
    Portfolio.transaction do
      portfolio = Portfolio.new(portfolio_params)
      @designer.portfolio = portfolio
      update_potfolio_pictures(portfolio, params[:portfolio])
      redirect_after_updated(portfolio)
    end
  end

  private

  def set_designer
    check_designer
    @designer = Designer.find(session[:designer_id])
  end

  def set_portfolio
    @portfolio = @designer.portfolio
  end

  def portfolio_params
    result = params.require(:portfolio).permit(:years_of_expirience, :education_gifted, :degree, :school_name,
      :education_apprenticed, :education_school, :awards, :style_description, :about, :path)
    [:education_gifted, :education_school, :education_apprenticed].each do |param|
      result[param] = to_bool(result[param])
    end
    result
  end

  def redirect_after_updated(portfolio)
    if portfolio.complete?
      redirect_to show_portfolio_path(url: portfolio.path)
    else
      redirect_to edit_portfolio_path
    end
  end

  def update_potfolio_pictures(portfolio, portfolio_params)
    portfolio_pictures_ids = portfolio_params[:picture_ids].try(:split, ',').try(:map, &:to_i)
    personal_picture_id = portfolio_params[:personal_picture_id]
    background_picture_id = portfolio_params[:background_picture_id]
    Image.update_portfolio(portfolio, background_picture_id, personal_picture_id, portfolio_pictures_ids)
  end
end
