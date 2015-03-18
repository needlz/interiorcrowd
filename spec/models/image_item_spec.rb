require 'rails_helper'

RSpec.describe Designer do
  let(:image) { Fabricate(:image) }
  let(:product_item) { Fabricate(:product_item, image: image) }

  it 'destroys dependent images' do
    product_item.destroy
    expect(Image.exists?(image.id)).to be_falsey
  end

end
