require "rails_helper"

RSpec.describe Portfolio do
  let(:portfolio) { Fabricate(:portfolio) }
  let(:designer) { Fabricate(:designer) }
  let(:other_designer) { Fabricate(:designer) }

  it 'has unique designer' do
    designer.portfolio = portfolio
    other_designer.portfolio = portfolio
    expect(other_designer.reload.portfolio).to eq portfolio
    expect(designer.reload.portfolio).to be_nil
  end

  describe 'degree validation' do
    it 'raises error for unknown value' do
      expect { portfolio.update_attributes!(degree: 'kkk') }.to raise_error
    end

    it 'allows known value' do
      Portfolio::DEGREES.each do |degree|
        portfolio.update_attributes!(degree: degree)
        expect(portfolio.degree).to eq degree
      end
    end
  end

  describe 'generation of unique path' do
    before do
      portfolio.path = ''
      designer.portfolio = portfolio
      designer.first_name = 'John'
      designer.last_name = 'Snow'
    end

    it 'returns designer\'s name if there are no portfolios with same path' do
      portfolio.assign_unique_path
      expect(portfolio.path).to eq 'john_snow'
    end

    it 'returns designer\'s name with index if there are portfolios with same path' do
      Fabricate(:portfolio, path: 'john_snow')
      portfolio.assign_unique_path
      expect(portfolio.path).to eq 'john_snow_1'
    end

    it 'returns designer\'s name with unique index if there are portfolios with same name and with index' do
      Fabricate(:portfolio, path: 'john_snow')
      Fabricate(:portfolio, path: 'john_snow_1')
      portfolio.assign_unique_path
      expect(portfolio.path).to eq 'john_snow_2'
    end

    it 'returns designer\'s name with unique index if there are portfolios with same name and with wrong index' do
      Fabricate(:portfolio, path: 'john_snow')
      Fabricate(:portfolio, path: 'john_snow_2')
      portfolio.assign_unique_path
      expect(portfolio.path).to eq 'john_snow_1'
    end
  end

  describe 'update links' do
    let(:links) { ['link1', '', 'link2'] }
    it 'updates links' do
      portfolio.update_links(links)
      expect(portfolio.reload.example_links.pluck(:url)).to match_array(links.reject(&:empty?))
    end

    it 'doesn\'t destroy links if links not passed' do
      portfolio.update_links(links)
      portfolio.update_links(nil)
      expect(portfolio.reload.example_links.pluck(:url)).to match_array(links.reject(&:empty?))
    end
  end

  describe 'awards' do
    let(:awards) { ['award1', '', 'award2'] }

    it 'updates awards' do
      portfolio.update_awards(awards)
      expect(portfolio.reload.portfolio_awards.pluck(:name)).to match_array(awards.reject(&:empty?))
    end

    it 'doesn\'t destroy awards if awards not passed' do
      portfolio.update_awards(awards)
      portfolio.update_awards(nil)
      expect(portfolio.reload.portfolio_awards.pluck(:name)).to match_array(awards.reject(&:empty?))
    end
  end
end
