class AddMissingTimestamps2 < ActiveRecord::Migration
  def change
    add_timestamps :client_payments
    ActiveRecord::Base.connection.execute "UPDATE client_payments SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :contests_promocodes
    ActiveRecord::Base.connection.execute "UPDATE contests_promocodes SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :final_note_to_designers
    ActiveRecord::Base.connection.execute "UPDATE final_note_to_designers SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :portfolios
    ActiveRecord::Base.connection.execute "UPDATE portfolios SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :promocodes
    ActiveRecord::Base.connection.execute "UPDATE promocodes SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
    add_timestamps :sounds
    ActiveRecord::Base.connection.execute "UPDATE sounds SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
  end
end
