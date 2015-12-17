class ConceptBoardPage::DesignerPerspective::Finished < ::ConceptBoardPage::DesignerPerspective::Base

  def image_items_partial
    { partial: 'clients/client_center/entries/finished/finished_image_items',
      locals: { image_items: image_items.published.paginate(per_page: 10, page: @pagination_options[:image_items_page]),
                pagination: pagination } }
  end

  def paginated_image_items_partial
    page = @pagination_options[:image_items_page] || 1
    { partial: 'clients/client_center/entries/finished/finished_image_items',
      locals: { image_items: image_items.published.paginate(per_page: 10, page: page),
                pagination: pagination },
    }
  end

  def pagination
    { controller: 'designer_center_requests',
      action: 'show',
      id: contest_request.id }
  end

end
