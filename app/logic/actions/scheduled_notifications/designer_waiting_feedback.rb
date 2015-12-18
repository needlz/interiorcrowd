module ScheduledNotifications

  class DesignerWaitingFeedback < Scheduler

    WAITING_INTERVAL = 3.days

    def self.scope
      contests = Contest.joins([{ requests: [:comments] }, :client]).merge(ConceptBoardComment.by_designer).
        where(comment_created_after_last_visit).
          where(*waiting_period_passed_since_comment_created).where(client_not_yet_reminded).all.to_a.uniq
      contests.group_by(&:client).map { |client, contests| [client, contests.map(&:id)] }
    end

    def self.notification
      :designer_waiting_for_feedback_to_client
    end

    def self.send_notification(client_and_contests)
      client = client_and_contests[0]
      contests = client_and_contests[1]
      super([client.id, contests])
      client.update_attributes!(last_remind_about_feedback_at: Time.current)
    end

    private

    def self.comment_created_after_last_visit
      '(contest_requests.last_visit_by_client_at IS NULL) OR (concept_board_comments.created_at > contest_requests.last_visit_by_client_at)'
    end

    def self.waiting_period_passed_since_comment_created
      ['concept_board_comments.created_at < :range_end', { range_end: Time.current - WAITING_INTERVAL }]
    end

    def self.client_not_yet_reminded
      '(clients.last_remind_about_feedback_at IS NULL) OR (clients.last_remind_about_feedback_at < concept_board_comments.created_at)'
    end

  end

end
