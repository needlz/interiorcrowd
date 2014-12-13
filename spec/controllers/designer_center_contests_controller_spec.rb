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
  end

  describe 'GET show' do
    it 'returns page' do
      get :show, id: contest.id
      expect(response).to render_template(:show)
    end
  end

  describe 'GET responds' do
    before do
      contest.contest_requests << Fabricate(:contest_request, designer: designer)
      contest.contest_requests << Fabricate(:contest_request, designer: designer, status: 'fulfillment')
    end

    it 'returns page' do
      get :responds
      expect(response).to render_template(:responds)
    end
  end
end
