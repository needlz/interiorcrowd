class ImageItemView

  delegate :image_id, :text, :id, :mark, to: :image_item

  def self.for_image_items(image_items)
    image_items.map{ |image_item| new(image_item) }
  end

  def initialize(image_item)
    @image_item = image_item
  end

  def thumb_url
    image_item.medium_size_image_url || '/assets/portfolio_example.png'
  end

  private

  attr_reader :image_item

end
