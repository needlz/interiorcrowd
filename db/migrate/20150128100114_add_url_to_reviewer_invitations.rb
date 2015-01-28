class AddUrlToReviewerInvitations < ActiveRecord::Migration
  def change
    add_column :reviewer_invitations, :url, :string
  end
end
