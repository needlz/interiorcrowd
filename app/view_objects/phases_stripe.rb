class PhasesStripe

  PHASES = I18n.t('client_center.entries.phases')

  ACTIVE_STEP_TO_STEPS_CSS = ['stepOne', 'stepTwo', 'stepThree']

  def initialize(options)
    @active_step = options[:active_step]
    @last_step = options[:last_step]
    @view_context = options[:view_context]
    @status = options[:status]
    @contest_request = options[:contest_request]
    @step_url_renderer = options[:step_url_renderer]
  end

  def css_class(index)
    "#{ ACTIVE_STEP_TO_STEPS_CSS[index] } #{ 'active' if (active_step || last_step) == index }"
  end

  def text(index)
    title = PHASES[index].html_safe
    return view_context.link_to title, step_url_renderer.phase_url(index) if link?(index)
    title
  end

  private

  attr_reader :active_step, :view_context, :status, :contest_request, :last_step, :step_url_renderer

  def link?(index)
    step_url_renderer && available_step?(index)
  end

  def available_step?(index)
    previous_step = (index < active_step)
    performed_step = (active_step < index && index <= ContestPhases.status_to_index(status))
    previous_step || performed_step
  end

end
