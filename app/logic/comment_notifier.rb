class CommentNotifier

  def initialize(contest_request, user, comment)
    @contest_request = contest_request
    @user_role = user.class.name.downcase
    @author = user
    @comment = comment
  end

  def perform
    delayed_job = delayed_job_for_email
    delayed_job ? delay_sending_time(delayed_job) : send_email
  end

  private

  attr_reader :user_role, :contest_request, :author, :comment

  def send_email
    Jobs::Mailer.schedule(:comment_on_board,
                          [{ username: author.name,
                             email: user.email,
                             role: user_role,
                             search_by: "#{user_role}s_comment_on_board",
                             comment: comment.text
                           },
                           contest_request.id
                          ],
                          { run_at: digest_minutes_interval, contest_request_id: contest_request.id })
  end

  def delayed_job_for_email
    Delayed::Job.where('handler LIKE ? and contest_request_id = ?', "%#{user_role}s_comment_on_board%", contest_request.id).first
  end

  def delay_sending_time(delayed_job)
    delayed_job.update_attribute(:run_at, digest_minutes_interval)
  end

  def digest_minutes_interval
    Settings.comment_board_digest_minutes_interval.to_i.minutes.from_now.utc
  end

  def user
    return contest_request.designer if user_role == 'client'
    contest_request.contest.client
  end

end