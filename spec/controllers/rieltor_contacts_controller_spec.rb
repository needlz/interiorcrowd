require 'rails_helper'

RSpec.describe RieltorContactsController do
  render_views

  def rieltor_contact_params(options = {})
    { rieltor_contact: { first_name: '',
                         last_name: '',
                         brokerage: '',
                         email: '',
                         phone: ['', '', ''],
                         choice: '' }.deep_merge(options)
    }
  end

  describe 'GET sfar' do

    it 'renders page' do
      get :sfar
      expect(response).to render_template(:sfar)
    end

  end

  describe 'POST create' do

    it 'saves new contact' do
      expect{post :create, rieltor_contact_params({ choice: 'email_me',
                                                    email: 'test@example.com'})}.to change{RieltorContact.count}.by(1)
      expect(response).to redirect_to sfar_path(anchor: 'sfarSubmitButton')
    end

    it "doesn't save contact with non valid details" do
      expect{post :create, rieltor_contact_params({ choice: 'email_me',
                                                    email: 'fail@'})}.not_to change{RieltorContact.count}
      expect(response).to redirect_to sfar_path(anchor: 'sfarSubmitButton')
    end

  end

end
