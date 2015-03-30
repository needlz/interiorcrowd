class ConceptBoardPage

  def initialize(options)
    @contest_request = options[:contest_request]
    @preferred_view_index = options[:preferred_view].to_i if options[:preferred_view]
    @contest_request_view = options[:contest_request_view]
    @view_context = options[:view_context]

    @phases_stripe = PhasesStripe.new(active_step: selected_step || last_phase_index,
                                      last_step: last_phase_index,
                                      view_context: @view_context,
                                      status: @contest_request.status,
                                      contest_request: @contest_request,
                                      step_url_renderer: self)
  end

  def selected_step
    @preferred_view_index
  end

  private

  attr_reader :contest_request, :preferred_view_index, :contest_request_view, :view_context

  def phase_dependent_partial
    partial_by_view_index(preferred_view_index || last_phase_index)
  end

  def last_phase_index
    @last_index ||= ContestPhases.status_to_index(contest_request.status)
  end

  def partial_by_view_index(view_index)
    send(ContestPhases.index_to_phase(view_index))
  end

  def phase_url_params(index)
    path_params = { id: contest_request.id }
    path_params.merge!(view: index) if index != last_phase_index
    path_params
  end

end
