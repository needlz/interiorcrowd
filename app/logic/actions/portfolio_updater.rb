class PortfolioUpdater

  def initialize(options)
    @portfolio_options = options[:portfolio_options]
    @portfolio = options[:portfolio]
    @portfolio_attributes = options[:portfolio_attributes]
  end

  def perform
    portfolio.update_attributes!(portfolio_attributes) if attributes_updated?
    return unless portfolio_options
    update_pictures if pictures_updated?
    update_awards if awards_updated?
    update_links if example_links_updated?
  end

  private

  attr_reader :portfolio_options, :portfolio, :portfolio_attributes

  def update_pictures
    portfolio_pictures_ids = portfolio_options[:picture_ids].try(:split, ',').try(:map, &:to_i)
    personal_picture_id = portfolio_options[:personal_picture_id]
    Image.update_portfolio(portfolio, personal_picture_id, portfolio_pictures_ids)
  end

  def update_links
    portfolio.example_links.destroy_all
    portfolio_options[:example_links].each do |link|
      portfolio.example_links.create!(url: link) if link.present?
    end
  end

  def update_awards
    portfolio.portfolio_awards.destroy_all
    portfolio_options[:awards].each do |award|
      portfolio.portfolio_awards.create!(name: award) if award.present?
    end
  end

  def pictures_updated?
    portfolio_options[:picture_ids] || portfolio_options[:personal_picture_id]
  end

  def awards_updated?
    portfolio_options[:awards]
  end

  def example_links_updated?
    portfolio_options[:example_links]
  end

  def attributes_updated?
    portfolio_attributes
  end

end
