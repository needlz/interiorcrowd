class MakeBudgetPlanInteger < ActiveRecord::Migration
  def change
    execute 'ALTER TABLE contests ALTER budget_plan TYPE integer USING budget_plan::int;'
  end
end
