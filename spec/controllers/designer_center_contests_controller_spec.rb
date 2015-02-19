require 'rails_helper'

RSpec.describe DesignerCenterContestsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

  before do
    sign_in(designer)
  end

  describe 'GET index' do
    it 'returns page' do
      get :index
      expect(response).to render_template(:index)
    end

    describe 'list of contests the designer was invited to' do
      context 'designer has no invitations' do
        it 'is empty' do
          get :index
          expect(assigns(:invited_contests)).to be_empty
        end
      end

      context 'designer has invitations' do
        before do
          Fabricate(:designer_invite_notification, user_id: designer.id, contest: contest)
        end

        it 'returns list of invitation contests' do
          get :index
          expect(assigns(:invited_contests).map(&:id)).to match_array [contest.id]
        end
      end
    end
  end

  describe 'GET show' do
    it 'returns page' do
      get :show, id: contest.id
      expect(response).to render_template(:show)
    end
  end

  describe 'GET index' do
    before do
      contest.requests << Fabricate(:contest_request, designer: designer)
      contest.requests << Fabricate(:contest_request, designer: designer, status: 'fulfillment')
    end

    it 'returns page' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
