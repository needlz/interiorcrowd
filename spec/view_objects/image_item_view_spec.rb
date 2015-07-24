require 'rails_helper'

RSpec.describe ImageItemView do
  let(:contest) { Fabricate(:contest, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }
  let(:image_item) { Fabricate(:product_item, mark: image_item_mark, contest_request: contest_request) }
  let(:published_image_item) { Fabricate(:product_item, temporary_version: image_item, mark: published_mark,
                                         contest_request: contest_request) }
  let(:image_item_mark) { ImageItem::MARKS[:LIKE] }
  let(:published_mark) { ImageItem::MARKS[:DISLIKE] }

  context "hasn't the published version" do
    it 'shows its own mark' do
      view = ImageItemView.new(image_item)
      expect(view.mark).to eq image_item_mark
    end
  end

  context "hasn't the published version and hasn't own mark" do
    before do
      image_item.update_attribute(:mark, nil)
      published_image_item
    end

    it 'shows its own mark' do
      view = ImageItemView.new(image_item)
      expect(view.mark).to eq published_mark
    end
  end

  context 'has the published version' do
    before do
      published_image_item
    end

    it 'shows the mark of the published item' do
      view = ImageItemView.new(image_item)
      expect(view.mark).to eq image_item_mark
    end
  end

end