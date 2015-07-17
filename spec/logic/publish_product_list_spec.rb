require 'rails_helper'

RSpec.describe PublishProductList do

  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client, status: 'fulfillment') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, status: 'fulfillment_ready') }
  let(:temporary_items) { Fabricate.times(2, :product_item, contest_request: contest_request, status: 'temporary') }
  let(:published_items) { Fabricate.times(3, :product_item, contest_request: contest_request, status: 'published') }
  let(:publish) { PublishProductList.new(contest_request) }

  describe 'publishing' do
    context 'when no published items yet' do
      before do
        temporary_items
      end

      it 'create published copy of temporary items' do
        publish.perform
        expect(contest_request.image_items.published.count).to eq 2
        expect(contest_request.image_items.temporary.find{ |item| item.published_version.blank? }).to be_nil
      end
    end

    context 'when published items present' do
      before do
        temporary_items
        published_items
      end

      it 'create published copy of temporary items' do
        publish.perform
        expect(contest_request.image_items.published.count).to eq 2
        expect(contest_request.image_items.temporary.find{ |item| item.published_version.blank? }).to be_nil
      end

      it 'removes old published items' do
        publish.perform
        expect(contest_request.image_items.published.count).to eq 2
        items_with_old_published_ids = contest_request.image_items.where(id: published_items.map(&:id))
        expect(items_with_old_published_ids.count).to eq 0
      end
    end
  end

end
