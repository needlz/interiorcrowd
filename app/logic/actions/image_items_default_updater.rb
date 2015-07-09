class ImageItemsDefaultUpdater

  def self.update_existing(image_item, item_attributes)
    prepared_attributes = assign_item_attributes(image_item, item_attributes)
    image_item.update_attributes!(prepared_attributes)
  end

  def self.create_with_attributes(items_scope, item_attributes)
    items_scope.create!(item_attributes)
  end

  private

  def self.assign_item_attributes(image_item, attributes)
    attributes.delete_if { |key, value| value.nil? }
    assign_attributes(image_item, attributes)
    attributes
  end

  def self.assign_attributes(image_item, attributes)
    image_item.assign_attributes(attributes)
    attributes.merge!({ mark: nil }) if image_item.image_id_changed?
  end

end
