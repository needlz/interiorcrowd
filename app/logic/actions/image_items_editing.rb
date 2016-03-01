class ImageItemsEditing
  attr_accessor  :has_new_product_items

  def initialize(options)
    @contest_request_options = options[:contest_request_options]
    @items_scope = options[:items_scope]
    @new_items_attributes = options[:new_items_attributes]
    @has_new_product_items = false
    @items_updater = options[:image_items_updater]
  end

  def perform
    ImageItem::KINDS.each do |kind|
      if !contest_request_options || contest_request_options[kind]
        product_items_attributes = gather_attributes(kind)
        clear_items(kind, product_items_attributes)
        update_items(kind, product_items_attributes)
      end
    end
  end

  private

  attr_reader :contest_request_options, :items_scope, :new_items_attributes

  def gather_attributes(kind)
    return [] unless contest_request_options
    ids = contest_request_options[kind][:ids]
    ids.each_with_index.map do |id, index|
      { attributes:
            { image_id: contest_request_options[kind][:image_ids][index],
              name: contest_request_options.dig(kind, :names, index),
              brand: contest_request_options.dig(kind, :brands, index),
              price: contest_request_options.dig(kind, :prices, index),
              link: contest_request_options.dig(kind, :links, index),
              text: contest_request_options.dig(kind, :texts, index),
              dimensions: contest_request_options.dig(kind, :dimensions, index)
            },
        id: id
      }
    end
  end

  def clear_items(kind, product_items_attributes)
    items_ids = product_items_attributes.map{ |item| item[:id] }
    items_scope.send(kind).where.not(id: items_ids).destroy_all
  end

  def update_items(kind, product_items_attributes)
    product_items_attributes.each do |product_item_attributes|
      if product_item_attributes[:id].present?
        product_item = items_scope.send(kind).find(product_item_attributes[:id])
        @items_updater.update_existing(product_item, product_item_attributes)
      else
        item_attributes = product_item_attributes[:attributes]
        item_attributes.merge!(new_items_attributes) if new_items_attributes
        created_item = @items_updater.create_with_attributes(items_scope.send(kind), item_attributes)
        @has_new_product_items ||= created_item
      end
    end
  end

  def to_money(value)
    value.to_money if value.present?
  end

end
