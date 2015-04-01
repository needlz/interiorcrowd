class EntriesConceptBoard < ConceptBoardPage

  protected

  def create_phases_stripe
    PhasesStripe.new(last_step: last_phase_index,
                     view_context: @view_context,
                     status: @contest_request.status,
                     contest_request: @contest_request)
  end

end
