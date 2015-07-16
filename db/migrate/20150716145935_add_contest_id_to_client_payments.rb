class AddContestIdToClientPayments < ActiveRecord::Migration
  def change
    add_reference :client_payments, :contest, index: true
  end
end
