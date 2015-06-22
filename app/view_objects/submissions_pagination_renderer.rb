class SubmissionsPaginationRenderer < WillPaginate::ActionView::LinkRenderer

  protected

  def page_number(page)
    unless page == current_page
      link(page, page, rel: rel_value(page))
    else
      tag(:span, page, class: 'activePageNumber')
    end
  end

  def previous_or_next_page(page, text, classname)
    if page
      link(text, page, class: classname)
    end
  end

  def html_container(html)
    tag(:ul, html, container_attributes)
  end

end
