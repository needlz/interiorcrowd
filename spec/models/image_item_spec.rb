require 'rails_helper'

RSpec.describe Designer do
  let(:image) { Fabricate(:image) }
  let(:contest_request) { Fabricate(:contest_request) }
  let(:product_item) { Fabricate(:product_item, image: image, contest_request: contest_request) }

  it 'destroys dependent images' do
    product_item.destroy
    expect(Image.exists?(image.id)).to be_falsey
  end

end
