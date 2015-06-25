class SwitchAllContestsToNewPackage < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute('UPDATE contests SET budget_plan = 1')
  end
end
