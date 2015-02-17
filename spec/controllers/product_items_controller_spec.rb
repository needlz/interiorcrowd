require 'rails_helper'

RSpec.describe ProductItemsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:contest_request) { Fabricate(:contest_request, designer: designer, contest: contest) }

  describe 'POST create' do
    def generate_params(options = {})
      { product_item:
            { contest_request_id: contest_request.id,
              image_id: Fabricate(:image).id,
              text: 'text' }
      }.merge(options)
    end

    context 'not logged in' do
      it 'redirects to designer login page' do
        post :create, generate_params
        expect(response).to redirect_to login_sessions_path
      end
    end

    context 'not creator of the response' do
      before do
        sign_in(Fabricate(:designer))
      end

      it 'doesn\'t create an item' do
        post :create, generate_params
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end

    context 'logged in as client' do
      before do
        sign_in(client)
      end

      it 'redirects to designer login page' do
        post :create, generate_params
        expect(response).to redirect_to login_sessions_path
      end
    end

    context 'logged in as designer' do
      before do
        sign_in(designer)
      end

      it 'creates an product item' do
        params = generate_params
        post :create, params
        product_item = contest_request.product_items.first
        expect(product_item.image_id).to eq params[:product_item][:image_id].to_i
        expect(product_item.text).to eq params[:product_item][:text]
      end
    end
  end

  describe 'PATCH update' do
    def generate_params(options = {})
      { product_item:
            { contest_request_id: contest_request.id,
              image_id: Fabricate(:image).id,
              text: 'new text' }
      }.merge(options)
    end

    let(:product_item){ Fabricate(:product_item, contest_request: contest_request) }

    context 'logged in as designer' do
      before do
        sign_in(designer)
      end

      it 'updates attributes' do
        params = generate_params(id: product_item.id)
        patch :update, params
        product_item.reload
        expect(product_item.text).to eq params[:product_item][:text]
        expect(product_item.image_id).to eq params[:product_item][:image_id].to_i
      end
    end

  end
end
