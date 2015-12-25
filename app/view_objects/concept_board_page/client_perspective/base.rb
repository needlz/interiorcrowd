class ConceptBoardPage::ClientPerspective::Base < ConceptBoardPage::Base

  def phase_url(index)
    view_context.client_center_entry_path(phase_url_params(index))
  end

  def partial
    phase_dependent_partial
  end

  def image_items
    super.published
  end

  def image_items_partial
    raise NotImplementedError
  end

  private

  def phase_url_params(index)
    path_params = { id: contest_request.contest.id }
    path_params.merge!(view: index) if index != phases_stripe.last_phase_index
    path_params
  end

  def collaboration
    if collaboration_phase_in_process?
      { partial: "clients/client_center/entries/#{contest_request.status}",
        locals: { request: contest_request, contest_page: @contest_page }
      }
    else
      { partial: "clients/client_center/entries/previous_phases/collaboration",
        locals: { request: contest_request, contest_page: @contest_page }
      }
    end
  end

  def final_design
    { partial: "clients/client_center/entries/#{contest_request.status}",
      locals: { request: contest_request, contest_page: @contest_page }
    }
  end

  def collaboration_phase_in_process?
    ContestPhases.index_to_phase(phases_stripe.last_phase_index) == :collaboration
  end

end
