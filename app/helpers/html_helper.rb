module HtmlHelper

  def list(collection, &block)
    collection.each do |item|
      css_class = cycle('odd', 'even', name: 'list_items')
      if item == collection.first
        css_class = css_class + ' first'
      end
      if item == collection.last
        css_class = css_class + ' last'
      end
      block.call(item, css_class)
    end
  end

end
