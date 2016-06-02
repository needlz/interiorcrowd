class SetHourlyPaymentDefaultStatus < ActiveRecord::Migration
  def change
    change_column_default :hourly_payments, :payment_status, 'pending'
  end
end
