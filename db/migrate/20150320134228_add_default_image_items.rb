class AddDefaultImageItems < ActiveRecord::Migration
  def change
    ContestRequest.includes(:image_items).all.each do |request|
      request.product_items.create!(text: I18n.t('designer_center.product_items.text_placeholder')) unless request.product_items.exists?
      request.similar_styles.create!(text: I18n.t('designer_center.product_items.text_placeholder')) unless request.product_items.exists?
    end
  end
end
