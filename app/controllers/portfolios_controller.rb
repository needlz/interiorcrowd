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
    @navigation = Navigation::DesignerCenter::Base.new(:portfolio)
  end

  def update
    Portfolio.transaction do
      porfolio_update = PortfolioUpdater.new(portfolio: @portfolio,
                                             portfolio_options: params[:portfolio],
                                             portfolio_attributes: portfolio_params)
      porfolio_update.perform
    end
    respond_to do |format|
      format.html { redirect_after_updated(@portfolio) }
      format.json { render nothing: true }
    end
  end

  private

  def set_portfolio
    @portfolio = @designer.portfolio
  end

  def portfolio_params
    result = params.require(:portfolio).permit(:years_of_experience, :education_gifted, :degree, :school_name,
      :education_apprenticed, :education_school, :awards, :style_description, :about, :path,
      *(Portfolio::STYLES.map{|style| "#{style}_style" }), :background_id, :cover_x_percents_offset,
      :cover_y_percents_offset)
    [:education_gifted, :education_school, :education_apprenticed].each do |param|
      result[param] = result[param].to_bool
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

  def pictures_updated?
    params[:portfolio][:picture_ids] || params[:portfolio][:personal_picture_id]
  end

  def awards_updated?
    params[:portfolio][:awards]
  end
end
