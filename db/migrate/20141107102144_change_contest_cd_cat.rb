class ChangeContestCdCat < ActiveRecord::Migration
  def up
    change_table :contests do |t|
      t.references :design_category
      t.remove :cd_cat
      t.remove :cd_other_cat
    end
  end

  def down
    change_table :contests do |t|
      t.remove :design_category_id
      t.string :cd_cat, limit: nil
      t.string :cd_other_cat
    end
  end
end
