module ConceptBoardPage::ClientPerspective::Collaboration

  extend ActiveSupport::Concern

  def image_items_partial
    { partial: 'clients/client_center/entries/collaboration/image_items_mark_phase',
      locals: { contest_page: @contest_page } }
  end

  def paginated_image_items_partial(kind = nil)
    options = paginated_data_options(kind)
    arguments_for_rendering(options)
  end

  def paginated_product_items(page)
    product_items.published.for_mark.paginate(per_page: self.class::IMAGE_ITEMS_PER_PAGE, page: page)
  end

  def paginated_similar_styles(page)
    similar_styles.published.for_mark.paginate(per_page: self.class::IMAGE_ITEMS_PER_PAGE, page: page)
  end

  def pagination
    { controller: 'contests', action: 'show', id: contest_request.contest.id }
  end

  def arguments_for_rendering(options)
    paginated_image_items = self.send("paginated_#{ options[:kind] }", options[:page])
    { partial: 'clients/client_center/entries/collaboration/image_block',
      locals: { choosable: true,
                title: t('designer_center.edit.products_list'),
                block_text: t('client_center.entries.collaboration.check_message'),
                image_items: paginated_image_items,
                pagination_param: options[:pagination_param],
                pagination: pagination }
    }
  end

  def paginated_data_options(kind)
    result = { pagination_param: '', page: 1, kind: kind }
    if kind
      pagination_param = "#{ kind }_page"
      result[:pagination_param] = pagination_param
      result[:page] = @pagination_options[pagination_param].to_i if @pagination_options[pagination_param].present?
      result
    else
      detect_paginated_data_options
    end
  end

  def detect_paginated_data_options
    ImageItem::KINDS.each do |image_item_kind|
      if @pagination_options["#{ image_item_kind }_page"].present?
        pagination_param = "#{ image_item_kind }_page"
        return { kind: image_item_kind,
                 pagination_param: pagination_param,
                 page: @pagination_options[pagination_param].to_i }
      end
    end
  end

end
