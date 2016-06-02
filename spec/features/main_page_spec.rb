require 'rails_helper'

RSpec.feature 'Payment details' do
  scenario 'client', js: true do
    visit '/'
  end
end
