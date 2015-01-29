class CreateReviewerInvitations < ActiveRecord::Migration
  def change
    create_table :reviewer_invitations do |t|
      t.string :username
      t.string :email
      t.references :contest, index: true
    end
  end
end
