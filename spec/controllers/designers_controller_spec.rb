require 'rails_helper'

RSpec.describe DesignersController do
  render_views

  describe '#create' do

    let(:designer_creation_params) do
      {
        designer: { ex_document_ids: 137,
                    first_name: 'First',
                    last_name: 'Last',
                    email: 'address@example.com',
                    zip: '123',
                    password: '123',
                    password_confirmation: '123'
        }
      }
    end

    let(:portfolio_images) { [Fabricate(:image), Fabricate(:image)] }
    let(:portfolio_links) { ['link1', 'link2'] }

    let(:portfolio_params) do
      {
        portfolio: {
            picture_ids: portfolio_images.map(&:id).join(','),
            example_links: portfolio_links
        }
      }
    end

    it 'creates new designer' do
      expect(Designer.count).to eq 0
      post :create, designer_creation_params
      expect(Designer.count).to eq 1
    end

    it 'redirects to designer center' do
      post :create, designer_creation_params
      expect(response).to redirect_to designer_center_index_path
    end

    context 'portfolio passed' do
      it 'creates portfolio' do
        post :create, designer_creation_params.merge(portfolio_params)
        expect(Designer.first.portfolio.pictures).to match_array portfolio_images
        expect(Designer.first.portfolio.example_links.map(&:url)).to match_array portfolio_links
      end
    end
  end
end
