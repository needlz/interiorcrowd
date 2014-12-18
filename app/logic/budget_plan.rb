class BudgetPlan

  def initialize(attributes)
    @id = attributes[:id]
    @price = attributes[:price]
    @designs_count = attributes[:designs_count]
    @money_back_guarantee = attributes[:money_back_guarantee]
    @name = attributes[:name]
  end

  PLANS = [new(id: 1, price: 99, designs_count: 2, money_back_guarantee: false, name: 'budget'),
           new(id: 2, price: 199, designs_count: 10, money_back_guarantee: false, name: 'premier'),
           new(id: 3, price: 299, designs_count: 15, money_back_guarantee: true, name: 'premium')]

  attr_reader :id, :price, :designs_count, :money_back_guarantee

  def name
    I18n.t("contests.creation.plans.#{ @name }")
  end

  def self.find(id)
    plan = PLANS.find { |plan| plan.id == id.to_i }
    raise ArgumentError unless plan
    plan
  end

  def self.all
    PLANS
  end
end
