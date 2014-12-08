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
end
