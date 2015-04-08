class AddImageTypeToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :image_type, :string
  end
end
