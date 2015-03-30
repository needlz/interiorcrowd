class ConceptBoardEditing < ConceptBoardPage

  attr_reader :phases_stripe

  def phase_url(index)
    view_context.edit_designer_center_response_path(phase_url_params(index))
  end

  def view_partial
    phase_dependent_partial
  end

  private

  def initial
    { partial: 'designer_center_requests/edit/concept_board_editing_layout',
      locals: { request: contest_request }
    }
  end

  def product_list
    { partial: 'designer_center_requests/edit/image_items_editing_layout',
      locals: { request: contest_request }
    }
  end

  def final_design
    { partial: 'designer_center_requests/edit/final_upload',
      locals: { contest_request: contest_request,
                image_items: contest_request_view.image_items }
    }
  end

end
