require 'rails_helper'

RSpec.describe ImageItem do

  let(:contest_request) { Fabricate(:contest_request) }
  let(:temporary_item) { Fabricate(:product_item, phase: 'final_design', contest_request: contest_request, final: false) }
  let(:published_item) do
    published_item = temporary_item.dup
    published_item.temporary_version_id = temporary_item.id
    published_item.save!
    published_item
  end

  describe 'validation of uniqueness of phase, temporary_item_id, and final columns' do
    it 'does not allow to create multiple published items for the same temporary item' do
      published_item

      second_published_item = temporary_item.dup
      second_published_item.temporary_version_id = temporary_item.id
      expect { second_published_item.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows to have many temporary items' do
      temporary_item
      expect { Fabricate(:product_item, phase: 'collaboration', contest_request: contest_request) }.to_not raise_error
    end

    it 'allows to have multiple published items for the same temporary item with different phases' do
      published_item

      second_published_item = temporary_item.dup
      second_published_item.temporary_version_id = temporary_item.id
      second_published_item.phase = 'collaboration'
      expect { second_published_item.save! }.to_not raise_error
    end

    it 'allows to have multiple published items for the same temporary item if one of them is final' do
      published_item

      second_published_item = temporary_item.dup
      second_published_item.temporary_version_id = temporary_item.id
      second_published_item.final = true
      expect { second_published_item.save! }.to_not raise_error
    end
  end

end
