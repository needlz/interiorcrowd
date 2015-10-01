require 'rails_helper'

RSpec.describe LookbookDetail do
  describe 'validations' do
    it 'does not allow to create lookbook details without image' do
      expect { Fabricate(:lookbook_detail) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'allows to create lookbook details with image' do
      expect { Fabricate(:lookbook_image) }.to_not raise_error
    end
  end
end
