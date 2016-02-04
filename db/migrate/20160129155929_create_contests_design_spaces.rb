class CreateContestsDesignSpaces < ActiveRecord::Migration
  def up
    return if table_exists? :contests_design_spaces
    create_table :contests_design_spaces, id: false do |t|
      t.references :contest, index: true, foreign_key: true
      t.references :design_space, index: true, foreign_key: true
      t.index [:contest_id, :design_space_id], unique: true, name: 'contests_on_design_spaces'
    end

    Contest.all.each do |contest|
      design_space = DesignSpace.find_by_id(contest.design_space_id)
      contest.design_spaces << design_space if design_space
    end
  end

  def down
    add_column :contests, :design_space_id, :integer unless column_exists? :contests, :design_space_id
    Contest.all.each do |contest|
      design_space = contest.design_spaces.present? ? contest.design_spaces[0] : DesignSpace.find(1)
      contest.update_attributes!(design_space_id: design_space.id)
    end

    drop_table :contests_design_spaces
  end
end
