class AddRetailersToContests < ActiveRecord::Migration
  def change
    change_table :contests do |t|
      %w(anthropologie_home ballard_designs crate_and_barrel etsy gilt horchow ikea one_kings_lane pier_one
         pottery_barn restoration_hardware room_and_board target wayfair west_elm).each do |retailer|
        t.boolean "retailer_#{ retailer }".to_sym, default: false
      end
      t.text :retailer
    end
  end
end
