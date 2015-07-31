class MoveContestsToFinalStatus < ActiveRecord::Migration
  def change
    Contest.where(status: 'fulfillment').each do |contest|
      response = contest.response_winner
      response_status = response.try(:status)
      if response_status == 'fulfillment_approved'
        contest.update_column(:status, 'final_fulfillment')
      end
    end
  end
end
