class PackageView

  SERVICES = {
      designers: [{ message: 'contests.creation.preview.expect_designers', count_variable: :designer_count }],
      moodboard: [{ message: 'contests.creation.packages.moodboard' }],
      product_list: [{ message: 'contests.creation.packages.product_list'}, { message: 'contests.creation.packages.up_to_products', count_variable: :product_count }],
      floor_plan: [{ message: 'contests.creation.packages.floor_plan' }],
      rendering: [{ message: 'contests.creation.packages.3d_rendering' }]
  }

  delegate :name, :id, :price, to: :plan

  def initialize(plan)
    @plan = plan
  end

  def services
    plan.services.map do |service_key|
      service_texts = SERVICES[service_key]
      service_texts.map do |service|
        if service.has_key?(:count_variable)
          count = plan.send(service[:count_variable])
          I18n.t(service[:message], count: count, service[:count_variable] => count)
        else
          I18n.t(service[:message])
        end
      end.join('<br>')
    end.flatten
  end

  def name
    I18n.t("contests.creation.plans.#{ plan.name }")
  end

  private

  attr_reader :plan

end
