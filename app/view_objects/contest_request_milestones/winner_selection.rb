module ContestRequestMilestones

  class WinnerSelection < Base

    def designer_hint
      if expired_request_during_winner_selection?
        I18n.t('designer_center.milestones.winner_selection.submission_closed')
      elsif in_progress?
        I18n.t('designer_center.milestones.winner_selection.time_left', time_left: time_left)
      else
        I18n.t('designer_center.milestones.winner_selection.expired')
      end
    end

  end

end
