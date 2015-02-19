class ImageItemsEditing

  def initialize(contest_request, contest_request_options)
    @contest_request_options = contest_request_options
    @contest_request = contest_request
  end

  def perform
    ImageItem::KINDS.each do |kind|
      if contest_request_options[kind]
        product_items_attributes = gather_attributes(kind)
        clear_items(kind, product_items_attributes)
        update_items(kind, product_items_attributes)
      end
    end
  end

  private

  def gather_attributes(kind)
    image_ids = contest_request_options[kind][:image_ids].split(',')
    attributes = image_ids.each_with_index.map do |image_id, index|
      { attributes:
            { image_id: image_id,
              text: contest_request_options[kind][:texts][index]
            },
        id: contest_request_options[kind][:ids][index]
      }
    end
  end

  def clear_items(kind, product_items_attributes)
    contest_request.send(kind).where.not(id: product_items_attributes.map{ |item| item[:id] }).destroy_all
  end

  def update_items(kind, product_items_attributes)
    product_items_attributes.each do |product_item_attributes|
      if product_item_attributes[:id].present?
        product_item = contest_request.send(kind).find(product_item_attributes[:id])
        update_item(product_item, product_item_attributes[:attributes])
      else
        contest_request.send(kind).create!(product_item_attributes[:attributes])
      end
    end
  end

  def update_item(product_item, attributes)
    assign_attributes(product_item, attributes)
    product_item.update_attributes!(attributes)
  end

  def assign_attributes(product_item, attributes)
    product_item.assign_attributes(attributes)
    attributes.merge!({ mark: nil }) if product_item.image_id_changed?
  end

  attr_reader :contest_request, :contest_request_options

end
