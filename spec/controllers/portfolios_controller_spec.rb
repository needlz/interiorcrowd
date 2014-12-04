require 'rails_helper'
require 'spec_helper'

RSpec.describe PortfoliosController do
  include PortfoliosHelper

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }

  describe 'GET show' do
    before do
      designer.update_attributes!(portfolio_path: 'portfolio_name')
    end

    it 'renders page' do
      get :show, url: designer.portfolio_path
      expect(response).to be_ok
    end

    it 'raises error if unknown portfolio passed' do
      expect { get :show, url: 'unknown' }.to raise_error
    end
  end

  describe 'GET edit' do
    it 'can not be accessed by anonymous user' do
      expect { get :edit }.to raise_error
    end

    it 'can not be accessed by client' do
      sign_in(client)
      expect { get :edit }.to raise_error
    end

    context 'when signed in as designer' do
      before do
        sign_in(designer)
      end

      context 'with rendered views' do
        render_views

        it 'renders attribute inputs' do
          get :edit
          portfolio_attributes.each do |attribute|
            expect(response).to render_template(partial: "portfolios/forms/_#{ attribute }")
          end
        end
      end
    end
  end

  describe 'POST update' do
    let(:new_portfolio_path) { 'my_portfolio' }
    it 'can not be requested by anonymous user' do
      expect { patch :update, designer: { years_of_expirience: '1' } }.to raise_error
    end

    it 'can not be requested by client' do
      sign_in(client)
      expect { patch :update }.to raise_error
    end

    context 'if signed in as designer' do
      before do
        sign_in(designer)
      end

      it 'redirects to portfolio view if portfolio published' do
        patch :update, designer: { portfolio_path: new_portfolio_path, portfolio_published: true }
        expect(response).to redirect_to show_portfolio_path(url: new_portfolio_path)
      end

      it 'redirects to portfolio view if portfolio not published' do
        patch :update, designer: { portfolio_path: new_portfolio_path }
        expect(response).to redirect_to edit_portfolio_path
      end

      it 'updates years_of_expirience' do
        new_years_of_expirience = '1'
        patch :update, designer: { years_of_expirience: new_years_of_expirience, portfolio_path: 'path' }
        expect(designer.reload.years_of_expirience).to eq new_years_of_expirience.to_i
      end
    end
  end
end
