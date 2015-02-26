class AddTokenToContestRequests < ActiveRecord::Migration
  def change
    add_column :contest_requests, :token, :string

    requests = execute('SELECT * FROM contest_requests')
    requests.each do |row|
      token = TokenGenerator.generate
      execute("UPDATE contest_requests SET token = '#{ token }' WHERE id=#{ row['id'] }")
    end
  end
end
