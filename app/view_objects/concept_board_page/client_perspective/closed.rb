class ConceptBoardPage::ClientPerspective::Closed < ConceptBoardPage::ClientPerspective::Base

  def image_items_partial
    { partial: 'clients/client_center/entries/finished/finished_image_items', locals: { contest_page: @contest_page } }
  end

end
