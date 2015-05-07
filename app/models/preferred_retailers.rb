class PreferredRetailers < ActiveRecord::Base

  RETAILERS = %i(anthropologie_home ballard_designs crate_and_barrel etsy gilt horchow ikea one_kings_lane pier_one
         pottery_barn restoration_hardware room_and_board target wayfair west_elm)

  has_one :contest

  def name
    "Preferred retailers list #{ id }"
  end

end

