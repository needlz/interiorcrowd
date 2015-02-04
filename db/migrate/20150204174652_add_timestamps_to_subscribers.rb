class AddTimestampsToSubscribers < ActiveRecord::Migration
  def change
    add_timestamps :beta_subscribers
    execute "UPDATE beta_subscribers SET created_at='#{ Time.now }', updated_at='#{ Time.now }'"
  end
end
