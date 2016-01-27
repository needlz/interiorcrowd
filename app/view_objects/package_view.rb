class PackageView

  SERVICE_TEXT_TEMPLATES = {
      multiple_designs: [{ message: 'contests.creation.packages.multiple_designs' }],
      collaboration: [{ message: 'contests.creation.packages.collaboration'}],
      in_person_meeting: [{ message: 'contests.creation.packages.in_person_meeting'}],
  }

  delegate :id, :price, to: :plan

  def initialize(plan)
    @plan = plan
  end

  def services
    plan.services.map do |service_key|
      service_text_template = SERVICE_TEXT_TEMPLATES[service_key]
      service_text_rows = service_text_template.map { |template_row| template_row_to_text(template_row) }
      service_text_rows.join('<br>')
    end.flatten
  end

  def template_row_to_text(template_row)
    if template_row.has_key?(:count_variable)
      count = plan.send(template_row[:count_variable])
      I18n.t(template_row[:message], count: count, template_row[:count_variable] => count)
    else
      I18n.t(template_row[:message])
    end
  end

  def name
    return unless plan
    I18n.t("contests.creation.plans.#{ plan.name }").html_safe
  end

  private

  attr_reader :plan

end
