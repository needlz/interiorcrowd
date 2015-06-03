require 'rails_helper'

RSpec.describe PortfolioUpdater do

  let(:portfolio) { Fabricate(:portfolio) }

  describe 'update links' do
    let(:links) { ['link1', '', 'link2'] }
    it 'updates links' do
      update = PortfolioUpdater.new(portfolio: portfolio, portfolio_options: { example_links: links })
      update.perform
      expect(portfolio.reload.example_links.pluck(:url)).to match_array(links.reject(&:empty?))
    end

    it 'doesn\'t destroy links if links not passed' do
      update = PortfolioUpdater.new(portfolio: portfolio, portfolio_options: { example_links: links })
      update.perform
      update = PortfolioUpdater.new(portfolio: portfolio)
      update.perform
      expect(portfolio.reload.example_links.pluck(:url)).to match_array(links.reject(&:empty?))
    end
  end

  describe 'awards' do
    let(:awards) { ['award1', '', 'award2'] }

    it 'updates awards' do
      update = PortfolioUpdater.new(portfolio: portfolio, portfolio_options: { awards: awards })
      update.perform
      expect(portfolio.reload.portfolio_awards.pluck(:name)).to match_array(awards.reject(&:empty?))
    end

    it 'doesn\'t destroy awards if awards not passed' do
      update = PortfolioUpdater.new(portfolio: portfolio, portfolio_options: { awards: awards })
      update.perform
      update = PortfolioUpdater.new(portfolio: portfolio)
      update.perform
      expect(portfolio.reload.portfolio_awards.pluck(:name)).to match_array(awards.reject(&:empty?))
    end
  end

end
