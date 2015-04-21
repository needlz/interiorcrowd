class ImageItemMarkView

  attr_reader :text, :css_class

  def initialize(checked_mark)
    return @css_class = 'item-mark' if checked_mark.blank?
    @text = I18n.t("designer_center.product_items.#{ checked_mark }")
    @css_class = "#{ checked_mark }Mark item-mark"
  end

end
