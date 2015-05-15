class EntriesConceptBoard < ConceptBoardPage

  def phase_url(index)
    view_context.entries_client_center_index_path(phase_url_params(index))
  end

  def partial
    phase_dependent_partial
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
    path_params = {}
    path_params.merge!(view: index) if index != last_phase_index
    path_params
  end

  def initial
    { partial: "clients/client_center/entries/previous_phases/initial",
      locals: { request: contest_request }
    }
  end

  def collaboration
    if collaboration_phase_in_process?
      { partial: "clients/client_center/entries/#{contest_request.status}",
        locals: { request: contest_request }
      }
    else
      { partial: "clients/client_center/entries/previous_phases/collaboration",
        locals: { request: contest_request }
      }
    end
  end

  def final_design
    { partial: "clients/client_center/entries/#{contest_request.status}",
      locals: { request: contest_request }
    }
  end

  def collaboration_phase_in_process?
    ContestPhases.index_to_phase(last_phase_index) == :collaboration
  end

end
