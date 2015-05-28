class ContestNoteCreation

  def initialize(contest, text, current_user)
    @contest = contest
    if current_user.client?
      @client_id = current_user.id
      @client = Client.find(current_user.id)
    end
    @designer_id = current_user.id if current_user.designer?
    @text = text.strip
  end

  def perform
    comment = contest.notes.create!(text: text, client_id: client_id, designer_id: designer_id)
    notify_designers(comment) if client_id
  end

  private

  attr_reader :client_id, :designer_id, :contest, :text, :client

  def notify_designers(comment)
    subscribed_designers_ids.each do |designer|
      ContestCommentDesignerNotification.create!(contest_comment_id: comment.id, user_id: designer.id)
      duplicate_in_concept_board_inbox(comment, designer)
      send_email(designer)
    end
  end

  def subscribed_designers_ids
    contest.subscribed_designers
  end

  def send_email(designer)
    delayed_job = delayed_job_for_email(designer.id)
    delayed_job ? delay_sending_time(delayed_job) : schedule_email(designer)
  end

  def schedule_email(designer)
    Jobs::Mailer.schedule(:note_to_concept_board,
                          [{ username: designer.name,
                             email: designer.email,
                             client_name: client.name,
                             comment: text }],
                          { run_at: digest_minutes_interval, contest_id: contest.id })
  end

  def delayed_job_for_email(designer_id)
    Delayed::Job.where('handler LIKE ? and contest_id = ?', "%note_to_designer: #{designer_id}%", contest.id).first
  end

  def delay_sending_time(delayed_job)
    delayed_job.update_attribute(:run_at, digest_minutes_interval)
  end

  def digest_minutes_interval
    Settings.comment_board_digest_minutes_interval.to_i.minutes.from_now.utc
  end

  def duplicate_in_concept_board_inbox(comment, designer)
    contest_request = contest.response_of(designer)
    if contest_request
      ConceptBoardComment.create!(user_id: client_id,
                                  role: 'Client',
                                  contest_request_id: contest_request.id,
                                  contest_note_id: comment.id)
    end
  end

end
