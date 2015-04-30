class AddColorPreferencesToContest < ActiveRecord::Migration
  def change
    add_column :contests, :designers_explore_other_colors, :boolean, default: false
    add_column :contests, :designers_only_use_these_colors, :boolean, default: false
  end
end
