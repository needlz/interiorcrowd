class CreateJoinTableContestPromocode < ActiveRecord::Migration
  def change
    create_join_table :contests, :promocodes do |t|
      t.index [:contest_id, :promocode_id]
      t.index [:promocode_id, :contest_id]
    end

    clients_promocodes_rows = ActiveRecord::Base.connection.execute("SELECT * FROM clients_promocodes")
    clients_promocodes_rows.each do |row|
      client = Client.find(row['client_id'])
      client.contests.each do |contest|
        contest.promocodes << Promocode.find(row['promocode_id'])
      end
    end
  end
end
