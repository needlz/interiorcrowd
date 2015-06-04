class PortfolioCreation

  def initialize(options)
    @designer_id = options[:designer_id]
    @portfolio_options = options[:portfolio_options]
  end

  def perform
    portfolio = Portfolio.create!(designer_id: designer_id)
    portfolio_update = PortfolioUpdater.new(portfolio: portfolio, portfolio_options: portfolio_options)
    portfolio_update.perform
  end

  private

  attr_reader :designer_id, :portfolio_options

end
