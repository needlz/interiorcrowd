class ContestRequestEditing

  def initialize(options)
    @request = options[:request]
    @contest_request = options[:contest_request]
  end

  def perform
    update_image
    update_text
    update_status
    update_product_list
  end

  private

  def update_image
    if contest_request[:image_id]
      lookbook_id = request.lookbook.id
      details = LookbookDetail.find_by_lookbook_id(lookbook_id)
      details.update(image_id: contest_request[:image_id])
    end
  end

  def update_text
    if contest_request[:feedback]
      request.update(feedback: contest_request[:feedback])
    end
  end

  def update_status
    request.submit! if contest_request[:status] == 'submitted'
    request.ready_fulfillment! if contest_request[:status] == 'fulfillment_ready' && request.fulfillment?
  end

  def update_product_list
    if contest_request[:product_items]
      product_items_attributes = gather_product_items_attributes
      clear_product_list(product_items_attributes)
      update_product_items(product_items_attributes)
    end
  end

  def gather_product_items_attributes
    image_ids = contest_request[:product_items][:image_ids].split(',')
    product_items_attributes = image_ids.each_with_index.map do |image_id, index|
      { attributes:
        { image_id: image_id,
          text: contest_request[:product_items][:texts][index]
        },
        id: contest_request[:product_items][:ids][index]
      }
    end
  end

  def clear_product_list(product_items_attributes)
    request.product_items.where.not(id: product_items_attributes.map{ |item| item[:id] }).destroy_all
  end

  def update_product_items(product_items_attributes)
    product_items_attributes.each do |product_item_attributes|
      if product_item_attributes[:id].present?
        product_item = request.product_items.find(product_item_attributes[:id])
        product_item.assign_attributes(product_item_attributes[:attributes])
        product_item_attributes[:attributes].merge!({ mark: nil }) if product_item.image_id_changed?
        product_item.update_attributes!(product_item_attributes[:attributes])
      else
        request.product_items.create!(product_item_attributes[:attributes])
      end
    end
  end

  attr_reader :request, :contest_request

end