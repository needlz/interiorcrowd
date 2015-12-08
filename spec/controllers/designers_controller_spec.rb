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
                    password_confirmation: '123',
                    state: 'Alabama',
                    phone_number: '123',
                    address: 'Elm Street',
                    city: 'city'
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

    it 'sets attributes' do
      post :create, designer_creation_params
      attributes = designer_creation_params[:designer]
      designer = Designer.last
      expect(designer.first_name).to eq attributes[:first_name]
      expect(designer.last_name).to eq attributes[:last_name]
      expect(designer.email).to eq attributes[:email]
      expect(designer.zip).to eq attributes[:zip]
      expect(designer.state).to eq attributes[:state]
      expect(designer.phone_number).to eq attributes[:phone_number]
      expect(designer.address).to eq attributes[:address]
      expect(designer.city).to eq attributes[:city]
    end

    it 'redirects to portfolio editing page' do
      post :create, designer_creation_params
      expect(response).to redirect_to edit_portfolio_path
    end

    it 'creates mail job' do
      post :create, designer_creation_params
      expect(jobs_with_handler_like('designer_registered').count).to eq 1
      expect { DelayedJob.all.each(&:invoke_job) }.to_not raise_error
    end

    context 'portfolio passed' do
      it 'creates portfolio' do
        post :create, designer_creation_params.merge(portfolio_params)
        expect(Designer.first.portfolio.pictures.reload).to match_array portfolio_images
        expect(Designer.first.portfolio.example_links.map(&:url)).to match_array portfolio_links
      end
    end

    it 'creates welcome notification' do
      post :create, designer_creation_params
      expect(Designer.first.user_notifications.length).to eq 1
    end
  end
end
