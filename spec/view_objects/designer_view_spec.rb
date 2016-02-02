require 'rails_helper'

RSpec.describe DesignerView do

  let(:image) { Fabricate(:image) }

  context 'designer has portfolio' do
    let(:portfolio) { Fabricate(:portfolio, personal_picture: image) }
    let(:designer) { Fabricate(:designer, portfolio: portfolio) }
    let(:designer_view) { DesignerView.new(designer) }

    it 'returns path to portfolio' do
      expect(designer_view.portfolio_path.present?).to be_truthy
    end

    context 'portfolio has avatar' do
      let(:portfolio) { Fabricate(:portfolio, personal_picture: image) }
      let(:designer) { Fabricate(:designer, portfolio: portfolio) }
      let(:designer_view) { DesignerView.new(designer) }

      it 'returns designer avatar' do
        expect(designer_view.designer_personal_picture).to eq(portfolio.personal_picture.medium_size_url)
      end
    end

    context 'portfolio has no avatars' do
      let(:portfolio) { Fabricate(:portfolio) }
      let(:designer) { Fabricate(:designer, portfolio: portfolio) }
      let(:designer_view) { DesignerView.new(designer) }

      it 'returns standard avatar stub' do
        expect(designer_view.designer_personal_picture).to eq(Settings.designer_note_profile_image)
      end
    end

  end

end