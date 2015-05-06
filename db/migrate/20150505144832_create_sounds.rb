class CreateSounds < ActiveRecord::Migration
  def change
    create_table :sounds do |t|
      t.references :contest_request
    end
  end
end
