class Contests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.string  :cd_cat
      t.string  :cd_other_cat
      t.string  :cd_space
      t.integer :cd_feminine_scale
      t.integer :cd_elegant_scale
      t.integer :cd_traditional_scale
      t.integer :cd_conservative_scale
      t.integer :cd_muted_scale
      t.integer :cd_timeless_scale
      t.integer :cd_fancy_scale
      t.string  :cd_fav_color
      t.string  :cd_refrain_color
      t.string  :cd_style_ex_images
      
      t.string  :cd_style_links
      t.string :cd_space_images
      
      t.integer :cd_space_flength
      t.integer :cd_space_ilength
      t.integer :cd_space_fwidth
      t.integer :cd_space_iwidth
      t.integer :cd_space_fheight
      t.integer :cd_space_iheight
      t.integer :cd_space_budget
      t.text :feedback
      t.string :project_name
      t.string :budget_plan
      t.integer :user_id
      
      t.timestamps
    end
  end
end
