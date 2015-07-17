class AddStatusToImageItems < ActiveRecord::Migration
  def up
    add_column :image_items, :status, :string, default: 'temporary'
    ContestRequest.where(status: ['fulfillment_ready', 'fulfillment_approved', 'finished']).each do |contest_request|
      contest_request.image_items.update_all('status = \'temporary\'')
      create_items_published_copy(contest_request.image_items)
    end
    ContestRequest.where(status: ['fulfillment']).each do |contest_request|
      contest_request.image_items.update_all('status = \'temporary\'')
    end

    ContestRequest.where(status: 'fulfillment').update_all('status = \'fulfillment_ready\'')
  end

  def down
    ImageItem.where(status: 'published').destroy_all
    remove_column :image_items, :status
  end

  def create_items_published_copy(image_items_scope)
    items = image_items_scope.all
    items.each do |item|
      item_copy = item.dup
      item_copy.status = 'published'
      item_copy.temporary_version_id = item.id
      item_copy.save!
    end
  end
end
