class ProductListPaginationRenderer < WillPaginate::ActionView::LinkRenderer

  protected

  def page_number(page)
    unless page == current_page
      link(page, page, rel: rel_value(page), class: 'pageLink')
    else
      tag(:em, page, class: 'current makeMeBold pageLink')
    end
  end

  def previous_or_next_page(page, text, classname)
    if page
      link(text, page, class: classname + ' makeMeBold pageLink')
    end
  end

  def html_container(html)
    tag(:ul, html, container_attributes)
  end

end
