class ImageItemView
  include ContestsHelper

  delegate :image_id, :text, :id, :mark, :medium_size_image_url, :name, :brand, :dimensions, :price, :link, :kind, to: :image_item

  def self.for_image_items(image_items)
    image_items.map{ |image_item| new(image_item) }
  end

  def initialize(image_item)
    @image_item = image_item
  end

  def thumb_url
    image_item.medium_size_image_url || '/assets/portfolio_example.png'
  end

  def link_href
    force_link_protocol(image_item.link)
  end

  private

  attr_reader :image_item

end
