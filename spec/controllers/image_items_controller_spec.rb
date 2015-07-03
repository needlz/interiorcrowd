require 'rails_helper'

RSpec.describe ImageItemsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, designer: designer, contest: contest) }

  describe 'POST create' do
    def generate_params(options = {})
      { image_item:
            { contest_request_id: contest_request.id,
              image_id: Fabricate(:image).id,
              text: 'text',
              kind: 'product_items'
            }
      }.merge(options)
    end

    context 'not logged in' do
      it 'redirects to designer login page' do
        post :create, generate_params
        expect(response).to redirect_to designer_login_sessions_path
      end
    end

    context 'not creator of the response' do
      before do
        sign_in(Fabricate(:designer))
      end

      it 'doesn\'t create an item' do
        post :create, generate_params
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'logged in as client' do
      before do
        sign_in(client)
      end

      it 'redirects to designer login page' do
        post :create, generate_params
        expect(response).to redirect_to designer_login_sessions_path
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
        expect(product_item.image_id).to eq params[:image_item][:image_id].to_i
        expect(product_item.text).to eq params[:image_item][:text]
      end
    end
  end

  describe 'PATCH update' do
    def generate_params(options = {})
      { image_item:
            { contest_request_id: contest_request.id,
              image_id: Fabricate(:image).id,
              text: 'new text',
              price: '$30.5 per roll (need 4-6 rolls)',
              brand: 'new brand',
              link: 'new link',
              dimensions: 'dimensions'
            }
      }.merge(options)
    end

    let(:product_item){ Fabricate(:product_item, contest_request: contest_request, mark: 'ok') }

    context 'logged in as designer' do
      before do
        sign_in(designer)
      end

      it 'updates attributes' do
        params = generate_params(id: product_item.id)
        patch :update, params
        product_item.reload
        expect(product_item.text).to eq params[:image_item][:text]
        expect(product_item.image_id).to eq params[:image_item][:image_id].to_i
        expect(product_item.link).to eq params[:image_item][:link]
        expect(product_item.price).to eq params[:image_item][:price]
        expect(product_item.brand).to eq params[:image_item][:brand]
        expect(product_item.dimensions).to eq params[:image_item][:dimensions]
      end

      it 'renders partial' do
        params = generate_params(id: product_item.id)
        patch :update, params
        expect(response).to render_template(partial: 'designer_center_requests/edit/_image_content')
      end
    end
  end

  describe 'PATCH mark' do
    let(:new_mark){ 'remove' }

    def generate_params
      { image_item:
            { mark: new_mark },
        id: product_item.id
      }
    end

    let(:product_item){ Fabricate(:product_item, contest_request: contest_request, mark: 'ok') }

    before do
      sign_in(client)
    end

    it 'updates mark' do
      params = generate_params
      patch :mark, params
      product_item.reload
      expect(product_item.mark).to eq new_mark
    end
  end

  describe 'GET default' do
    before do
      sign_in(designer)
    end

    it 'returns partial' do
      get :default, kind: 'product_items', contest_request_id: contest_request.id
      expect(response).to render_template(partial: 'designer_center_requests/edit/_image_content')
    end
  end

end
