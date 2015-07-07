class BudgetPlan

  def initialize(attributes)
    @id = attributes[:id]
    @price = attributes[:price]
    @designer_count = attributes[:designer_count]
    @product_count = attributes[:product_count]
    @name = attributes[:name]
    @services = attributes[:services]
  end

  def price_in_cents
    price * 100
  end

  PLANS = [new(id: 1,
               price: 299,
               name: 'first',
               services: [:multiple_desings, :collaboration, :concept_board, :product_list, :floor_plan])
  ]

  attr_reader :id, :price, :designer_count, :product_count, :services, :name

  def self.find(id)
    plan = PLANS.find { |plan| plan.id == id.to_i }
    raise ArgumentError unless plan
    plan
  end

  def self.all
    PLANS
  end
end
