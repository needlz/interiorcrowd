require "rails_helper"

RSpec.describe Designer do
  let(:designer) { Fabricate(:designer) }

  describe '#create_portfolio' do
    let(:images) { [Fabricate(:image), Fabricate(:image)] }
    let(:links) { ['link1', 'link2'] }
    let(:portfolio_params) do
      {
        picture_ids: images.map(&:id).join(','),
        example_links: links
      }
    end

    it 'creates portfolio' do
      designer.create_portfolio(portfolio_params)
      expect(designer.portfolio).to be_present
    end

    it 'creates portfolio if only one of parameter is present' do
      portfolio_params.each do |key, value|
        designer.create_portfolio({ key => value })
        expect(designer.reload.portfolio).to be_present
        designer.portfolio.destroy
      end
    end
  end

end
