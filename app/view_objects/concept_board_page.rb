class ConceptBoardPage

  attr_reader :phases_stripe

  def initialize(options)
    @contest_request = options[:contest_request]
    @preferred_view_index = options[:preferred_view].to_i if options[:preferred_view]
    @contest_request_view = options[:contest_request_view]
    @view_context = options[:view_context]

    @phases_stripe = create_phases_stripe
  end

  def selected_step
    @preferred_view_index
  end

  def image_items
    contest_request.visible_image_items(active_phase).for_view
  end

  protected

  def create_phases_stripe
    PhasesStripe.new(active_step: active_step,
                     last_step: last_phase_index,
                     view_context: @view_context,
                     status: @contest_request.status,
                     contest_request: @contest_request,
                     step_url_renderer: self)
  end

  private

  attr_reader :contest_request, :preferred_view_index, :contest_request_view, :view_context

  def active_step
    selected_step || last_phase_index
  end

  def active_phase
    ContestPhases.index_to_phase(active_step)
  end

  def phase_dependent_partial
    send(active_phase)
  end

  def last_phase_index
    @last_index ||= ContestPhases.status_to_index(contest_request.status)
  end

  def phase_url_params(index)
    path_params = { id: contest_request.id }
    path_params.merge!(view: index) if index != last_phase_index
    path_params
  end

end
