class ConceptBoardPage::ClientPerspective::Finished < ConceptBoardPage::ClientPerspective::Base

  def image_items_partial
    paginated_image_items_partial
  end

  def paginated_image_items_partial
    page = @pagination_options[:image_items_page] || 1
    { partial: 'clients/client_center/entries/finished/finished_image_items',
      locals: { image_items: image_items.published.paginate(per_page: 10, page: page),
                pagination: { controller: 'contests',
                              action: 'show',
                              id: contest_request.contest.id } },
    }
  end

  def show_contest_creation_button?
    ClientContestCreationPolicy.for_client(contest_request.contest.client).create_contest.can?
  end

end
