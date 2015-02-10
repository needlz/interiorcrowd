class CreatePreferredRetailers < ActiveRecord::Migration
  def up
    retailers = %w(anthropologie_home ballard_designs crate_and_barrel etsy gilt horchow ikea one_kings_lane pier_one
         pottery_barn restoration_hardware room_and_board target wayfair west_elm)
    create_table :preferred_retailers do |t|
      retailers.each do |retailer|
        t.boolean retailer.to_sym, default: false
      end
      t.text :other
      t.timestamps
    end

    if column_exists? :contests, :retailer_anthropologie_home
      retailers.each do |retailer|
        remove_column :contests, "retailer_#{ retailer }".to_sym
      end
    end

    add_column :contests, :preferred_retailers_id, :integer unless column_exists? :contests, :preferred_retailers_id
    Contest.where(preferred_retailers_id: nil).each do |contest|
      contest.update_attributes!(preferred_retailers_id: PreferredRetailers.create!.id)
    end
  end

  def down
    drop_table :preferred_retailers
    remove_column :contests, :preferred_retailers_id
  end
end
