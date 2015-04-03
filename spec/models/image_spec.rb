require "rails_helper"

RSpec.describe Image do

  describe 'update_portfolio_image' do
    let!(:portfolio){ Fabricate(:portfolio) }
    let!(:portfolio_personal_picture){ Fabricate(:image, kind: Image::PORTFOLIO_PERSONAL, portfolio: portfolio) }

    it 'destroys previous image if image_id has been changed' do
      image = portfolio.personal_picture
      new_image = Fabricate(:image)
      Image.update_portfolio_image(portfolio, Image::PORTFOLIO_PERSONAL, new_image.id)
      expect(portfolio.reload.personal_picture).to eq new_image
      expect(Image.exists?(image.id)).to be_falsey
    end

    context 'image_id is integer' do
      let(:new_image_id){ Fabricate(:image).id }

      it 'does not destroy previous image if image_id is unchanged' do
        image = portfolio.personal_picture
        Image.update_portfolio_image(portfolio, Image::PORTFOLIO_PERSONAL, new_image_id)
        expect(image).to_not be_destroyed
      end
    end

    context 'image_id is string' do
      let(:new_image_id){ Fabricate(:image).id.to_s }

      it 'does not destroy previous image if image_id is unchanged' do
        image = portfolio.personal_picture
        Image.update_portfolio_image(portfolio, Image::PORTFOLIO_PERSONAL, new_image_id)
        expect(image).to_not be_destroyed
      end
    end
  end

  it 'has no likes' do
    image = Fabricate(:image)
    expect(image.likes_count).to eq 0
  end

end
