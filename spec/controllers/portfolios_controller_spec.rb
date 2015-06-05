require 'rails_helper'
require 'spec_helper'

RSpec.describe PortfoliosController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:not_owner) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }

  describe 'GET show' do
    before do
      designer.portfolio = Fabricate(:portfolio)
    end

    context 'not logged in' do
      it 'renders page' do
        get :show, url: designer.portfolio.path
        expect(response).to be_ok
      end

      it 'raises error if unknown portfolio passed' do
        get :show, url: 'unknown'
        expect(response).to have_http_status(:not_found)
      end

      it 'does not render invitation button' do
        get :show, url: designer.portfolio.path
        expect(response).to_not render_template('_invite_button')
      end

      it 'does not render edit button' do
        get :show, url: designer.portfolio.path
        expect(response).to_not render_template('_edit_button')
      end
    end

    context 'logged in as client' do
      before do
        sign_in(client)
        contest
      end

      it 'renders invitation button' do
        get :show, url: designer.portfolio.path
        expect(response).to render_template('_invite_button')
      end
    end

    context 'logged in as owner' do
      before do
        sign_in(designer)
      end

      it 'renders edit button' do
        get :show, url: designer.portfolio.path
        expect(response).to render_template('_edit_button')
      end
    end

    context 'logged in as other designer' do
      before do
        sign_in(not_owner)
      end

      it 'does not render edit button' do
        get :show, url: designer.portfolio.path
        expect(response).to_not render_template('_edit_button')
      end
    end
  end

  describe 'GET edit' do
    context 'portfolio created' do
      before do
        designer.portfolio = Fabricate(:portfolio)
      end

      it 'can not be accessed by client' do
        sign_in(client)
        get :edit
        expect(response).to redirect_to designer_login_sessions_path
      end

      context 'when signed in as designer' do
        before do
          sign_in(designer)
        end

        it 'renders page' do
          get :edit
          expect(response).to render_template(:edit)
        end
      end
    end

    it 'redirects to login page if user not logged' do
      get :edit
      expect(response).to redirect_to designer_login_sessions_path
    end
  end

  describe 'PATCH update' do
    before do
      designer.portfolio = Fabricate(:portfolio)
    end

    it 'can not be requested by anonymous user' do
      patch :update, portfolio: { years_of_experience: '1' }
      expect(response).to redirect_to designer_login_sessions_path
    end

    it 'can not be requested by client' do
      sign_in(client)
      patch :update
      expect(response).to redirect_to designer_login_sessions_path
    end

    context 'if signed in as designer' do
      before do
        sign_in(designer)
      end

      it 'updates years_of_experience' do
        new_years_of_experience = '1'
        patch :update, portfolio: { years_of_experience: new_years_of_experience, path: 'path' }
        expect(designer.portfolio.reload.years_of_experience).to eq new_years_of_experience.to_i
      end

      it 'updates personal picture' do
        picture = Fabricate(:image)
        patch :update, portfolio: { personal_picture_id: picture.id }
        expect(designer.portfolio.reload.personal_picture).to eq picture
      end

      it 'updates background picture' do
        picture = Fabricate(:image)
        patch :update, portfolio: { background_id: picture.id }
        expect(designer.portfolio.reload.background).to eq picture
      end

      it 'updates awards' do
        awards = ['award1', 'award2']
        patch :update, portfolio: { awards: awards }
        expect(designer.portfolio.reload.portfolio_awards.map(&:name)).to eq awards
      end

      it 'updates position of cover image' do
        patch :update, portfolio: { cover_x_percents_offset: '1', cover_y_percents_offset: '2' }
        expect(designer.portfolio.reload.cover_x_percents_offset).to eq 1
        expect(designer.portfolio.reload.cover_y_percents_offset).to eq 2
      end
    end
  end
end
