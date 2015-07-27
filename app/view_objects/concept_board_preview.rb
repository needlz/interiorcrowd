class ConceptBoardPreview < ConceptBoardPage

  def phase_url(index)
    view_context.designer_center_response_path(phase_url_params(index))
  end

  def image_items_partial
    phase_dependent_partial
  end

  def image_items
    return super.temporary if contest_request.fulfillment_ready?
    super.published
  end

  def finished?
    active_phase == :final_design
  end

  private

  def initial; end

  def collaboration
    { partial: 'designer_center_requests/show/image_items_creation_phase' }
  end

  def final_design
    { partial: 'designer_center_requests/show/image_items_final_phase' }
  end

end
