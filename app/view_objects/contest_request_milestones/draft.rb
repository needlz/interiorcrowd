module ContestRequestMilestones

  class Draft < Base

    def designer_hint
      I18n.t('designer_center.milestones.draft.time_left', time_left: time_left)
    end

  end

end
