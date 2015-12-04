class EntriesConceptBoard < ConceptBoardPage

  def phase_url(index)
    view_context.client_center_entry_path(phase_url_params(index))
  end

  def partial
    phase_dependent_partial
  end

  def image_items
    super.published
  end

  protected

  def create_phases_stripe
    PhasesStripe.new(active_step: active_step,
                     last_step: last_phase_index,
                     view_context: view_context,
                     status: contest_request.status,
                     contest_request: contest_request,
                     step_url_renderer: self)
  end

  private

  def phase_url_params(index)
    path_params = { id: contest_request.contest.id }
    path_params.merge!(view: index) if index != last_phase_index
    path_params
  end

  def collaboration
    if collaboration_phase_in_process?
      { partial: "clients/client_center/entries/#{contest_request.status}",
        locals: { request: contest_request, concept_board_page: self }
      }
    else
      { partial: "clients/client_center/entries/previous_phases/collaboration",
        locals: { request: contest_request, concept_board_page: self }
      }
    end
  end

  def final_design
    { partial: "clients/client_center/entries/#{contest_request.status}",
      locals: { request: contest_request, concept_board_page: self }
    }
  end

  def collaboration_phase_in_process?
    ContestPhases.index_to_phase(last_phase_index) == :collaboration
  end

end
