class ImageItemView
  include ContestsHelper

  delegate :image_id, :text, :id, :mark, :medium_size_image_url, :name,
           :brand, :dimensions, :price, :link, :kind, :published_version, to: :image_item

  attr_reader :mark

  def self.for_image_items(image_items)
    image_items.map{ |image_item| new(image_item) }
  end

  def initialize(image_item)
    @image_item = image_item
    @mark = image_item.mark || published_version.try(:mark)
  end

  def thumb_url
    image_item.medium_size_image_url || '/assets/portfolio_example.png'
  end

  def link_href
    force_link_protocol(image_item.link)
  end

  def mark_css_class
    if mark == ImageItem::MARKS[:LIKE]
      'greenHead'
    elsif mark == ImageItem::MARKS[:DISLIKE]
      'redHead'
    end
  end

  def mark_text
    if mark == ImageItem::MARKS[:LIKE]
      'Client likes'
    elsif mark == ImageItem::MARKS[:DISLIKE]
      'Client dislikes'
    end
  end

  private

  attr_reader :image_item

end
