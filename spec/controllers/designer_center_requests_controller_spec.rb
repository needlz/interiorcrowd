require 'rails_helper'

RSpec.describe DesignerCenterRequestsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:other_designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest) }
  let(:submitted_respond) { Fabricate(:contest_request, designer: designer, contest: contest, status: 'submitted', lookbook: Fabricate(:lookbook)) }
  let(:fulfillment_respond) { Fabricate(:contest_request, designer: designer, contest: contest, status: 'fulfillment') }
  let(:other_designers_respond) { Fabricate(:contest_request, designer: other_designer, contest: contest) }

  before do
    sign_in(designer)
  end

  describe 'GET show' do
    it 'returns page' do
      get :show, id: submitted_respond.id
      expect(response).to render_template(:show)
    end
  end

  describe 'GET index' do
    before do
      submitted_respond
      fulfillment_respond
      other_designers_respond
    end

    it 'returns page' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'lists index of a designer' do
      get :index
      expect(assigns(:responds)).to eq [submitted_respond, fulfillment_respond]
    end
  end

  describe 'PATCH update' do
    let(:new_feedback) { 'new feedback' }

    before do
      patch :update, id: submitted_respond.id, respond: { feedback: new_feedback }
    end

    it 'updates feedback of response' do
      expect(submitted_respond.reload.feedback).to eq new_feedback
    end
  end
end
