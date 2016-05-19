class AddTotalPriceInCentsToHourlyPayments < ActiveRecord::Migration
  def change
    add_column :hourly_payments, :total_price_in_cents, :integer
  end
end
