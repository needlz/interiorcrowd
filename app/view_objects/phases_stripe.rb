class PhasesStripe

  PHASES = I18n.t('client_center.entries.phases')

  ACTIVE_STEP_TO_STEPS_CSS =  [['stepActive', '', ''],
              ['step1', 'stepActive', 'bgBottom'],
              ['backgroundTopRight', 'step1', 'stepActive']]

  def initialize(options)
    @active_step = options[:active_step]
    @last_step = options[:last_step]
    @view_context = options[:view_context]
    @status = options[:status]
    @contest_request = options[:contest_request]
    @step_url_renderer = options[:step_url_renderer]
  end

  def css_class(index)
    ACTIVE_STEP_TO_STEPS_CSS[active_step || last_step][index]
  end

  def text(index)
    return view_context.link_to PHASES[index], step_url_renderer.phase_url(index) if link?(index)
    PHASES[index]
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
