class PackageView

  SERVICE_TEXT_TEMPLATES = {
      designers: [{ message: 'contests.creation.preview.expect_designers', count_variable: :designer_count }],
      moodboard: [{ message: 'contests.creation.packages.moodboard' }],
      product_list: [{ message: 'contests.creation.packages.product_list'},
                     { message: 'contests.creation.packages.up_to_products', count_variable: :product_count }],
      floor_plan: [{ message: 'contests.creation.packages.floor_plan' }],
      rendering: [{ message: 'contests.creation.packages.3d_rendering' }]
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
    I18n.t("contests.creation.plans.#{ plan.name }")
  end

  private

  attr_reader :plan

end
