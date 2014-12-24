require 'rails_helper'

RSpec.describe DesignersController do
  render_views

  describe '#create' do
    before do
      allow_any_instance_of(Mailer).to receive(:designer_registration).and_return(Hashie::Mash.new({ deliver: '' }))
    end

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

    it 'creates new designer' do
      expect(Designer.count).to eq 0
      post :create, designer_creation_params
      expect(Designer.count).to eq 1
    end

    it 'redirects to designer center' do
      post :create, designer_creation_params
      expect(response).to redirect_to designer_center_index_path
    end
  end
end
