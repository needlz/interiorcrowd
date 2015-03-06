require "rails_helper"

RSpec.describe PortfolioView do
  include Rails.application.routes.url_helpers

  let(:portfolio_view) { PortfolioView.new(Fabricate(:portfolio)) }

  describe '#exit_portfolio_path' do
    context 'logged in as a client' do
      let(:current_user) { Fabricate(:client) }

      it 'returns client center path' do
        expect(portfolio_view.exit_portfolio_path(current_user)).to eq client_center_index_path
      end
    end

    context 'logged in as a designer' do
      let(:current_user) { Fabricate(:designer) }

      it 'returns designer center path' do
        expect(portfolio_view.exit_portfolio_path(current_user)).to eq designer_center_index_path
      end
    end

    context 'not logged in' do
      let(:current_user) { nil }

      it 'returns root path' do
        expect(portfolio_view.exit_portfolio_path(current_user)).to eq root_path
      end
    end
  end

end
