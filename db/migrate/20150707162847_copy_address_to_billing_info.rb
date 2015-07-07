class CopyAddressToBillingInfo < ActiveRecord::Migration
  def change
    Client.all.each do |client|
      %w[address state zip city].each do |field|
        client.send("billing_#{ field }=", client.send(field)) if client.send("billing_#{ field }").blank?
      end
      client.save
    end
  end
end
