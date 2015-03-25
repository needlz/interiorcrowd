class FillSimilarStyles < ActiveRecord::Migration
  def change
    ContestRequest.includes(:image_items).all.each do |request|
      unless request.similar_styles.exists?
        request.image_items.create!(text: I18n.t('designer_center.product_items.text_placeholder'),
                                       kind: 'similar_styles')
      end
    end
  end
end
