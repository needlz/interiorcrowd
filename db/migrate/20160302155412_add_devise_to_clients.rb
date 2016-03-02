class AddDeviseToClients < ActiveRecord::Migration
  def self.up
    change_table(:clients) do |t|
      ## Database authenticatable
      # t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip
    end

    add_index :clients, :reset_password_token, unique: true
  end

  def self.down
    remove_column :clients, :encrypted_password
    remove_column :clients, :reset_password_token
    remove_column :clients, :reset_password_sent_at
    remove_column :clients, :remember_created_at
    remove_column :clients, :sign_in_count
    remove_column :clients, :current_sign_in_at
    remove_column :clients, :last_sign_in_at
    remove_column :clients, :current_sign_in_ip
    remove_column :clients, :last_sign_in_ip

    remove_index :clients, :reset_password_token
  end
end
