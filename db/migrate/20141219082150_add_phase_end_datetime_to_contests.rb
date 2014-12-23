class AddPhaseEndDatetimeToContests < ActiveRecord::Migration
  def change
    add_column :contests, :phase_end, :datetime
    time = quote(Time.current + 3.days)
    update("UPDATE contests SET phase_end = #{ time }")
  end
end
