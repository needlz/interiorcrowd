class ContestPromocode < ActiveRecord::Base
  self.table_name = 'contests_promocodes'

  belongs_to :contest
  belongs_to :promocode

end
