require 'rails_helper'
require 'spec_helper'

RSpec.describe BlogController do
  render_views

  describe 'GET blog_page' do
    context 'existing blog page' do
      it 'returns page' do
        blog_root = '/'
        get :blog_page, blog_page_path: blog_root
        expect(response).to have_http_status(:success)
      end
    end

    context 'non existing blog page' do
      it 'returns 404' do
        get :blog_page, blog_page_path: 'not_existing_page'
        expect(response).to have_http_status(:missing)
      end
    end

  end

end