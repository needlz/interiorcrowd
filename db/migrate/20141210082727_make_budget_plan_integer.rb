class MakeBudgetPlanInteger < ActiveRecord::Migration
  def up
    change_column :contests, :budget_plan, :integer
  end

  def down
    change_column :contests, :budget_plan, :string
  end
end
