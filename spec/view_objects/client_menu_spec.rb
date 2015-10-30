require 'rails_helper'

RSpec.describe ClientMenu do
  include Rails.application.routes.url_helpers

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:client_center_navigation) { Navigation::ClientCenter.new(:brief, contest: contest) }
  let(:menu_with_navigation) do
    ClientMenu.new(
      current_user: client,
      view_context: RenderingHelper.new,
      user_center_navigation: client_center_navigation
    )
  end
  let(:menu_without_navigation) do
    ClientMenu.new(
        current_user: client,
        view_context: RenderingHelper.new
    )
  end

  let(:brief_item) do
    client_center_item = menu.mobile_items.items.find { |item| item.name == 'Client center' }
    brief_item = client_center_item.children.find { |item| item.name == 'Brief' }
  end

  context 'object for user center navigation passed to constructor' do
    let(:menu) { menu_with_navigation }

    it 'uses user center navigation to generate navigation' do
      expect(brief_item.href).to eq brief_contest_path(id: contest.id)
    end
  end

  context 'object for user center navigation not passed to constructor' do
    let(:menu) { menu_without_navigation }

    it 'uses new object for user center navigation to generate navigation' do
      expect(brief_item.href).to eq client_center_entries_path
    end
  end

end
