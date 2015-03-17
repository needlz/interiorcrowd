class ImageItemMarkView

  attr_reader :text, :css_class

  def initialize(checked_mark)
    return if checked_mark.blank?
    @text = I18n.t("designer_center.product_items.#{ checked_mark }")
    @css_class = "#{ checked_mark }Mark"
  end

end
