require 'rails_helper'

RSpec.feature 'Main page', type: :feature do
  feature 'Logged as client', js: true do
    let!(:client) { Fabricate(:client) }
    let!(:contest) { Fabricate(:contest, client: client, status: 'incomplete') }

    scenario 'User opens beta page' do
      visit('/sessions/client_login/')
      fill_in('username', with: client.email)
      fill_in('password', with: client.plain_password)
      click_button('Sign In')

      expect(page.has_text?('CLIENT CENTER')).to be_truthy
    end
  end
end
