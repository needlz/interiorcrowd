class ChangeContestsCdSpace < ActiveRecord::Migration
  def up
    change_table :contests do |t|
      t.remove :cd_space
      t.references :design_space
    end
  end

  def down
    change_table :contests do |t|
      t.remove :design_space
      t.string :cd_space
    end
  end
end
