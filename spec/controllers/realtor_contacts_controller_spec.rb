require 'rails_helper'

RSpec.describe RealtorContactsController do
  render_views

  def realtor_contact_params(options = {})
    { realtor_contact: { first_name: '',
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
      expect{post :create, realtor_contact_params({choice: 'email_me',
                                                   email: 'test@example.com'})}.to change{RealtorContact.count}.by(1)
      expect(response).to redirect_to sfar_path(anchor: 'sfarSubmitButton')
    end

    it "doesn't save contact with non valid details" do
      expect{post :create, realtor_contact_params({choice: 'email_me',
                                                   email: 'fail@'})}.not_to change{RealtorContact.count}
      expect(response).to redirect_to sfar_path(anchor: 'sfarSubmitButton')
    end

  end

end
