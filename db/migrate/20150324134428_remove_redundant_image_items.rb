class RemoveRedundantImageItems < ActiveRecord::Migration
  def change
    ContestRequest.find_each do |request|
      request.product_items.where(image_id: nil).destroy_all if request.product_items.where.not(image_id: nil).exists?
      request.similar_styles.where(image_id: nil).destroy_all if request.similar_styles.where.not(image_id: nil).exists?
    end
  end
end
