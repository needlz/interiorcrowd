class ConceptBoardPage::DesignerPerspective::FulfillmentApproved < ::ConceptBoardPage::DesignerPerspective::Base

  def image_items_partial
    { partial: 'designer_center_requests/show/image_items_final_phase' }
  end

end
