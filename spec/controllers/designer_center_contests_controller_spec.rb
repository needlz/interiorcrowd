require 'rails_helper'

RSpec.describe DesignerCenterContestsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest_in_submission, client: client) }

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
          expect(assigns(:invited_contests).contests).to be_empty
        end
      end

      context 'designer has invitations' do
        before do
          Fabricate(:designer_invite_notification, user_id: designer.id, contest: contest)
        end

        it 'returns list of invitation contests' do
          get :index
          expect(assigns(:invited_contests).contests.map(&:id)).to match_array [contest.id]
        end
      end
    end
  end

  describe 'GET show' do
    it 'returns page' do
      dont_raise_i18n_exceptions do
        mock_file_download_url
        Fabricate(:example_image, contest: contest)
        Fabricate(:space_image, contest: contest)
        preference_name = ContestAdditionalPreference::PREFERENCES.first[0]
        preference_value = ContestAdditionalPreference::PREFERENCES.first[1][0]
        contest.update_attribute(preference_name, preference_value)
        contest.contests_appeals.create!(appeal_id: Appeal.create!(name: 'vintage').id)
        get :show, id: contest.id
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET index' do
    before do
      contest.requests << Fabricate(:contest_request, designer: designer)
      contest.requests << Fabricate(:contest_request, designer: designer, status: 'fulfillment_ready')
    end

    it 'returns page' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
