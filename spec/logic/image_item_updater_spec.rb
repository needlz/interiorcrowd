require 'rails_helper'

RSpec.describe ImageItemUpdater do

  let(:contest_request) { Fabricate(:contest_request) }
  let(:image_item) { Fabricate(:product_item, contest_request: contest_request) }
  let(:published_version) { Fabricate(:product_item, temporary_version: image_item, contest_request: contest_request) }

  before do
    mock_pubsub
  end

  describe 'updating image of an item' do
    context 'when published version exists' do
      before do
        published_version
      end

      it 'unlinks published version from the item' do
        updater = ImageItemUpdater.new(image_item, { image_id: 1 }, Anonym.new)
        updater.perform
        expect(image_item.published_version).to be_blank
      end
    end
  end

  describe 'not updating image of an item' do
    context 'when published version exists' do
      before do
        published_version
      end

      it 'leaves link to published version untouched' do
        updater = ImageItemUpdater.new(image_item, { name: 'chair' }, Anonym.new)
        updater.perform
        expect(image_item.published_version).to be_present
      end
    end
  end


end
