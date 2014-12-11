require 'rails_helper'

RSpec.describe DesignerCenterContestsController do
  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

  describe 'GET index' do
    before do
      sign_in(designer)
    end

    it 'returns ok' do
      get :index
      expect(response).to be_ok
    end
  end

  describe 'GET show' do
    before do
      sign_in(designer)
    end

    it 'returns ok' do
      get :show, id: contest.id
      expect(response).to be_ok
    end
  end
end
