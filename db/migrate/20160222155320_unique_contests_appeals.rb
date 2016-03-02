class UniqueContestsAppeals < ActiveRecord::Migration
  def change
    remove_index :contests_appeals, name: 'index_contests_appeals_on_appeal_id_and_contest_id'
    remove_index :contests_appeals, name: 'index_contests_appeals_on_contest_id_and_appeal_id'

    add_index "contests_appeals", ["appeal_id", "contest_id"], name: "index_contests_appeals_on_appeal_id_and_contest_id", using: :btree, unique: true
    add_index "contests_appeals", ["contest_id", "appeal_id"], name: "index_contests_appeals_on_contest_id_and_appeal_id", using: :btree, unique: true
  end
end
