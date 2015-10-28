require 'rails_helper'

RSpec.describe RieltorContactsController do

  describe 'GET sfar' do

    it 'renders page' do
      get :sfar
      expect(response).to render_template(:sfar)
    end

  end

end
