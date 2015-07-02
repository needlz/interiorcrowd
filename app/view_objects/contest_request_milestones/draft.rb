module ContestRequestMilestones

  class Draft < Base

    def designer_hint
      time_left = view_context.distance_of_time_in_words(Time.current,
                                                         contest.phase_end,
                                                         false,
                                                         highest_measure_only: true)
      I18n.t('designer_center.milestones.draft.time_left', time_left: time_left)
    end

  end

end
