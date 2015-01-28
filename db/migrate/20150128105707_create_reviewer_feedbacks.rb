class CreateReviewerFeedbacks < ActiveRecord::Migration
  def change
    create_table :reviewer_feedbacks do |t|
      t.text :text
      t.references :invitation, index: true
    end
  end
end
