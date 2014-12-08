require 'rails_helper'
require 'spec_helper'

RSpec.describe PortfoliosController do
  include PortfoliosHelper

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }

  describe 'GET show' do
    before do
      designer.portfolio = Fabricate(:portfolio)
    end

    it 'renders page' do
      get :show, url: designer.portfolio.path
      expect(response).to be_ok
    end

    it 'raises error if unknown portfolio passed' do
      get :show, url: 'unknown'
      expect(response).to render_template('errors/404')
    end
  end

  describe 'GET edit' do
    before do
      designer.portfolio = Fabricate(:portfolio)
    end

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

  describe 'PATCH update' do
    let(:new_portfolio_path) { 'my_portfolio' }

    before do
      designer.portfolio = Fabricate(:portfolio)
    end

    it 'can not be requested by anonymous user' do
      expect { patch :update, portfolio: { years_of_expirience: '1' } }.to raise_error
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
        patch :update, portfolio: { path: new_portfolio_path }
        expect(response).to redirect_to show_portfolio_path(url: new_portfolio_path)
      end

      it 'redirects to portfolio editing if portfolio not completed' do
        patch :update, portfolio: { path: '' }
        expect(response).to redirect_to edit_portfolio_path
      end

      it 'updates years_of_expirience' do
        new_years_of_expirience = '1'
        patch :update, portfolio: { years_of_expirience: new_years_of_expirience, path: 'path' }
        expect(designer.portfolio.reload.years_of_expirience).to eq new_years_of_expirience.to_i
      end

      it 'updates personal picture' do
        picture = Fabricate(:image)
        patch :update, portfolio: { personal_picture_id: picture.id }
        expect(designer.portfolio.reload.personal_picture).to eq picture
      end
    end
  end

  describe 'GET new' do
    before do
      sign_in(designer)
    end

    it 'returns page if portfolio was not created' do
      get :new
      expect(response).to be_ok
    end

    it 'redirects to edit page if portfolio was created' do
      designer.portfolio = Fabricate(:portfolio)
      get :new
      expect(response).to redirect_to edit_portfolio_path
    end
  end

  describe 'POST create' do
    before do
      sign_in(designer)
    end

    it 'creates portfolio' do
      expect(designer.portfolio).to_not be_present
      post :create, portfolio: { years_of_expirience: '1' }
      expect(designer.reload.portfolio).to be_present
    end
  end
end
