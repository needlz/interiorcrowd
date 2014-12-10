class BudgetPlan

  PLANS = [{ id: 1, price: 99, designs_count: 2, money_back_guarantee: false },
           { id: 2, price: 199, designs_count: 10, money_back_guarantee: false },
           { id: 3, price: 299, designs_count: 15, money_back_guarantee: true }]

  attr_reader :id, :price, :designs_count, :money_back_guarantee

  def initialize(plan_attributes)
    @id = plan_attributes[:plan_id]
    @price = plan_attributes[:price]
    @designs_count = plan_attributes[:designs_count]
    @money_back_guarantee = plan_attributes[:money_back_guarantee]
  end

  def self.find(id)
    plan_attributes = PLANS.find { |plan| plan[:id] == id.to_i }
    raise ActiveRecord::RecordNotFound unless plan_attributes
    new(plan_attributes)
  end

  def self.all
    result = []
    PLANS.each do |plan_attributes|
      result << new(plan_attributes)
    end
  end
end
