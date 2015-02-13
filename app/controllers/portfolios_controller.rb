class PortfoliosController < ApplicationController
  before_filter :set_designer, only: [:edit, :create, :update, :new]
  before_filter :set_portfolio, only: [:edit, :update, :new]

  def show
    portfolio = Portfolio.find_by_path(params[:url])
    raise_404 unless portfolio
    @client = Client.find_by_id(session[:client_id])
    @designer = Designer.find_by_id(session[:designer_id])
    @portfolio_view = PortfolioView.new(portfolio)
  end


  def edit
    @portfolio_view = PortfolioView.new(@portfolio)
    @navigation = Navigation::DesignerCenter.new(:portfolio)
  end

  def update
    Portfolio.transaction do
      @portfolio.update_attributes!(portfolio_params)
      @portfolio.update_pictures(params[:portfolio])
      @portfolio.update_awards(params[:portfolio][:awards])
    end
    redirect_after_updated(@portfolio)
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end

  def set_portfolio
    @portfolio = @designer.portfolio
  end

  def portfolio_params
    result = params.require(:portfolio).permit(:years_of_experience, :education_gifted, :degree, :school_name,
      :education_apprenticed, :education_school, :awards, :style_description, :about, :path,
      *(Portfolio::STYLES.map{|style| "#{style}_style" }), :background_id)
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
end
