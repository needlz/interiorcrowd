class PhasesStripe

  PHASES = I18n.t('client_center.entries.phases')

  STEPS_CSS_CLASSES = ['stepOne', 'stepTwo', 'stepThree']
  ACTIVENESS_CLASSES = ['stepOneActive', 'stepTwoActive', 'stepThreeActive']

  def initialize(options)
    @active_step = options[:selected_step]
    @last_step = options[:last_step]
    @view_context = options[:view_context]
    @contest_request_status = options[:contest_request_status]
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

  def active_step
    @active_step || last_step
  end

  def last_phase_index
    @last_step
  end

  def previous_step?
    active_step < last_phase_index
  end

  def active_phase
    ContestPhases.index_to_phase(active_step)
  end

  def winner_step?
    active_step >= ContestPhases.phase_to_index(:collaboration)
  end

  private

  attr_reader :view_context, :contest_request_status, :last_step, :step_url_renderer

  def link?(index)
    step_url_renderer && available_step?(index)
  end

  def available_step?(index)
    previous_step = (index < active_step)
    performed_step = (active_step < index && index <= ContestPhases.status_to_index(contest_request_status))
    previous_step || performed_step
  end

end
