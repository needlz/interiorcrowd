class CreateJoinTableContestAppeal < ActiveRecord::Migration
  def change
    create_table :contests_appeals do |t|
      t.references :contest
      t.references :appeal
      t.text :reason
      t.integer :value

      t.index [:contest_id, :appeal_id]
      t.index [:appeal_id, :contest_id]
    end

    Contest.all.each do |contest|
      Appeal.all.each do |appeal|
        contest.contests_appeals << ContestsAppeal.new(appeal_id: appeal.id,
                                                     contest_id: contest.id,
                                                     reason: '',
                                                     value: contest.send("#{appeal.first_name}_appeal_scale"))
      end
    end
  end
end
