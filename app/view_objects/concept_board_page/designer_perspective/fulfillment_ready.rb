class ConceptBoardPage::DesignerPerspective::FulfillmentReady < ::ConceptBoardPage::DesignerPerspective::Base

  def image_items_partial
    { partial: 'designer_center_requests/show/image_items_creation_phase' }
  end

end
