class RenameContestsColumns < ActiveRecord::Migration
  def change
    change_table :contests do |t|
      t.rename :cd_feminine_scale, :feminine_appeal_scale
      t.rename :cd_elegant_scale, :elegant_appeal_scale
      t.rename :cd_traditional_scale, :traditional_appeal_scale
      t.rename :cd_conservative_scale, :conservative_appeal_scale
      t.rename :cd_muted_scale, :muted_appeal_scale
      t.rename :cd_timeless_scale, :timeless_appeal_scale
      t.rename :cd_fancy_scale, :fancy_appeal_scale
      t.rename :cd_fav_color, :desirable_colors
      t.rename :cd_refrain_color, :undesirable_colors
      t.rename :cd_space_budget, :space_budget
    end
  end
end
