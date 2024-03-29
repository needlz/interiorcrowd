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

  def original_size_url
    image_item.image.try(:original_size_url) if image_item.image.try(:viewable?)
  end

  def download_url
    image_item.image.try(:url_for_downloading)
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
      I18n.t('designer_center.product_items.client_likes')
    elsif mark == ImageItem::MARKS[:DISLIKE]
      I18n.t('designer_center.product_items.client_dislikes')
    end
  end

  def mark_details
    id = image_item.temporary_version_id

    { id: id, text: mark_text, css_class: mark_css_class }
  end

  def link_text
    return '' if link.blank?
    get_link_base_url(link)
  end

  private

  attr_reader :image_item

end
