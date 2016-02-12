require 'rails_helper'
require 'spec_helper'

RSpec.describe BlogController do
  render_views

  describe 'GET blog_page' do
    context 'existing blog page' do
      it 'returns page' do
        stub_request(:get, "http://blog.interiorcrowd.com/?icrowd_app=yes").
           with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip,deflate', 'Cookie'=>'', 'Referer'=>'http://blog.interiorcrowd.com', 'User-Agent'=>'Faraday v0.9.1'}).
           to_return(:status => 200, :body => "", :headers => {})

        blog_root = '/'
        get :blog_page, blog_page_path: blog_root
        expect(response).to have_http_status(:success)
      end
    end
  end

end
