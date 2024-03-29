require 'rails_helper'
require 'spec_helper'

RSpec.describe LookbookDetailsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:lookbook) { Fabricate(:lookbook) }
  let(:contest_request) { Fabricate(:contest_request,
                                    designer: designer,
                                    status: 'fulfillment_ready',
                                    lookbook: lookbook) }
  let(:image) { Fabricate(:image) }
  let(:lookbook_detail_params) do
    { lookbook_detail: { image_id: image.id },
      designer_center_response_id: contest_request.id }
  end

  before do
    mock_file_download_url
  end

  describe 'POST create' do
    context 'logged as client' do
      before do
        sign_in(client)
      end

      it 'returns 404' do
        post :create, lookbook_detail_params
        expect(response).to redirect_to designer_login_sessions_path
        expect(lookbook.lookbook_details.count).to eq 1
      end
    end

    context 'not logged in' do
      it 'returns 404' do
        post :create, lookbook_detail_params
        expect(response).to redirect_to designer_login_sessions_path
        expect(lookbook.lookbook_details.count).to eq 1
      end
    end

    context 'logged as designer' do
      before do
        sign_in(designer)
      end

      it 'creates lookbook details' do
        post :create, lookbook_detail_params
        expect(response).to render_template('designer_center_requests/_showcase')
        expect(lookbook.lookbook_details.count).to eq 2
        expect(lookbook.lookbook_details.order(:created_at).last.image).to eq image
      end
    end
  end

  describe 'GET preview' do
    before do
      sign_in(designer)
    end

    let(:image_ids) { [Fabricate(:image).id, Fabricate(:image).id].join(',') }

    it 'returns preview' do
      get :preview, image_ids: image_ids
      expect(response).to render_template('designer_center_requests/_showcase')
    end
  end

  describe 'DELETE remove_preview' do
    before do
      sign_in(designer)
    end

    let(:image_ids) { [Fabricate(:image).id, Fabricate(:image).id].join(',') }

    it 'returns preview' do
      get :remove_preview, image_ids: image_ids
      expect(response).to render_template('designer_center_requests/_showcase')
      expect(Image.count).to eq 0
    end
  end

end
