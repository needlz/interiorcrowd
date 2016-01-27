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
               price: 99,
               name: 'first',
               services: [:multiple_desings, :collaboration, :concept_board, :product_list, :floor_plan])
  ]

  attr_reader :id, :price, :designer_count, :product_count, :services, :name

  def self.find(id)
    find_by_id(id) do |plan|
      raise ArgumentError unless plan
    end
  end

  def self.find_by_id(id, &after_search)
    plan = PLANS.find { |plan| plan.id == id.to_i }
    after_search.call(plan) if after_search
    plan
  end

  def self.all
    PLANS
  end
end
