module ContestRequestMilestones

  class Submitted < Base

    def designer_hint
      I18n.t('designer_center.milestones.submitted.time_left', time_left: time_left)
    end

  end

end
