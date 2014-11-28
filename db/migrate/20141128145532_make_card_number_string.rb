class MakeCardNumberString < ActiveRecord::Migration
  def up
    change_column(:clients, :card_number, :string)
  end

  def down
    change_column(:clients, :card_number, :integer)
  end
end
