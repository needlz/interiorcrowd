class MoveMilestonesToEndOfDay < ActiveRecord::Migration
  def change
    Contest.in_progress.where.not(phase_end: nil).each do |contest|
      contest.update_attributes!(phase_end: contest.phase_end.end_of_day)
    end
  end
end
