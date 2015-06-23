class PhasesStripe

  PHASES = I18n.t('client_center.entries.phases')

  STEPS_CSS_CLASSES = ['stepOne', 'stepTwo', 'stepThree']
  ACTIVENESS_CLASSES = ['stepOneActive', 'stepTwoActive', 'stepThreeActive']

  def initialize(options)
    @active_step = options[:active_step]
    @last_step = options[:last_step]
    @view_context = options[:view_context]
    @status = options[:status]
    @contest_request = options[:contest_request]
    @step_url_renderer = options[:step_url_renderer]
  end

  def css_class(index)
    STEPS_CSS_CLASSES[index]
  end

  def container_css_class
    ACTIVENESS_CLASSES[active_step || last_step]
  end

  def text(index)
    title = PHASES[index].html_safe
    link?(index) ? view_context.link_to(title, step_url_renderer.phase_url(index)) : title
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
