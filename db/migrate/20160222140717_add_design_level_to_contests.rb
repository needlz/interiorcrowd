class AddDesignLevelToContests < ActiveRecord::Migration
  def change
    add_column :contests, :designer_level_id, :integer

    Client.all.each do |client|
      client.contests.update_all(designer_level_id: client.designer_level_id)
    end
  end
end
