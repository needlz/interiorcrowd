class CopyDesignersContestNotesToContestRequestsComments < ActiveRecord::Migration
  def change
    ContestNote.where.not(designer_id: nil).each do |note|
      requests_found = ContestRequest.where(designer_id: note.designer_id, contest_id: note.contest_id)
      if requests_found.present?
        requests_found.last.comments.create!(user_id: note.designer_id, text: note.text, role: 'Designer', created_at: note.created_at)
      else
        new_request = note.contest.requests.create!(status: 'draft', designer_id: note.designer_id)
        new_request.comments.create!(user_id: note.designer_id, text: note.text, role: 'Designer', created_at: note.created_at)
      end
    end
  end
end
