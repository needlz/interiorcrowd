require 'rails_helper'

RSpec.feature 'Contest request page', type: :feature do
  feature 'Button for removing a concept board is visible on hover', js: true do
    let!(:client) { Fabricate(:client) }
    let!(:contest) { Fabricate(:contest_in_submission, client: client) }
    let!(:designer) { Fabricate(:designer_with_portfolio) }
    let!(:lookbook_item) do
      item = Fabricate(:lookbook_image, phase: 'initial')
      file_path = Rails.root.join('app/assets/images/avatar.png')
      file = File.open(file_path, 'r')
      item.image.image = file
      item.image.save!
      item
    end
    let!(:contest_request) { Fabricate(:contest_request,
                                       contest: contest,
                                       designer: designer,
                                       status: 'submitted',
                                       lookbook: Fabricate(:lookbook,
                                                           lookbook_details: [lookbook_item]
                                       )
                             )
    }

    before do
      mock_file_download_url
    end

    scenario 'User opens beta page' do
      visit('/sessions/designer_login/')
      fill_in('username', with: designer.email)
      fill_in('password', with: designer.plain_password)
      click_button('Sign In')

      visit("/designer_center/responses/#{ contest_request.id }/")

      expect(page).to_not have_css('.overlayExampleImg .remove img[src]')

      page.find('.showcase-content-container').hover
      expect(page).to have_css('.overlayExampleImg .remove img[src]')
    end
  end
end
