class BudgetPlan

  def initialize(attributes)
    @id = attributes[:id]
    @price = attributes[:price]
    @designer_count = attributes[:designer_count]
    @product_count = attributes[:product_count]
    @name = attributes[:name]
    @services = attributes[:services]
  end

  PLANS = [new(id: 1,
               price: 99,
               designer_count: 2,
               product_count: 4,
               name: 'budget',
               services: [:designers, :moodboard, :product_list]),
           new(id: 2,
               price: 199,
               designer_count: 5,
               product_count: 8,
               name: 'premier',
               services: [:designers, :moodboard, :product_list, :floor_plan]),
           new(id: 3,
               price: 299,
               designer_count: 5,
               product_count: 12,
               name: 'premium',
               services: [:designers, :moodboard, :product_list, :floor_plan, :rendering])
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
