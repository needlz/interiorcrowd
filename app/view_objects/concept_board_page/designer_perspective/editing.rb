class ConceptBoardPage::DesignerPerspective::Editing < ::ConceptBoardPage::Base

  def phase_url(index)
    view_context.edit_designer_center_response_path(phase_url_params(index))
  end

  def view_partial
    phase_dependent_partial
  end

  def image_items
    return super.published if contest_request.fulfillment_approved?
    super.temporary
  end

  private

  def initial
    { partial: 'designer_center_requests/edit/concept_board_editing_layout',
      locals: { request: contest_request }
    }
  end

  def collaboration
    { partial: 'designer_center_requests/edit/image_items_editing_layout',
      locals: { request: contest_request, editable: editable? }
    }
  end

  def final_design
    { partial: 'designer_center_requests/edit/final_upload',
      locals: { contest_request: contest_request,
                image_items: image_items }
    }
  end

end
