class AddMissingAppealContests < ActiveRecord::Migration
  def change
    Appeal.all.each do |appeal|
      Contest.all.each do |contest|
        contest_appeal = contest.contests_appeals.where(appeal_id: appeal.id).first_or_initialize
        contest_appeal.value = 50
        if contest_appeal.new_record?
          contest_appeal.save!
        end
      end
    end
  end
end
