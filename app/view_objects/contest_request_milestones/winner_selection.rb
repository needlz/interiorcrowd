module ContestRequestMilestones

  class WinnerSelection < Base

    def designer_hint
      if in_progress?
        I18n.t('designer_center.milestones.winner_selection.time_left', time_left: time_left)
      else
        I18n.t('designer_center.milestones.winner_selection.expired')
      end
    end

  end

end
