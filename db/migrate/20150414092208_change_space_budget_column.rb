class ChangeSpaceBudgetColumn < ActiveRecord::Migration
  def up
    change_column :contests, :space_budget, :string
    Contest.all.each do |contest|
      contest.update_attribute(:space_budget, budgets[contest.space_budget.to_i])
    end
  end

  def down
    Contest.all.each do |contest|
      contest.update_attribute(:space_budget, budgets.index(contest.space_budget))
    end
    change_column :contests, :space_budget, 'integer USING CAST(space_budget AS integer)'
  end

  def budgets
    ['0', '$0 - $200', '$201 - $500', '$501 - $1000', '$1001 - $1500', '$1501 - $2500',
     '$2501 - $3500', '$3501 - $5000', '$5001 - $7500', '$7501 - $10000', '$10000 +' ]

  end
end
