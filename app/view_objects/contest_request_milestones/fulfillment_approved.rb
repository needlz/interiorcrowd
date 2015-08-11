module ContestRequestMilestones

  class FulfillmentApproved < Base

    def designer_hint
      if in_progress?
        time_left = view_context.distance_of_time_in_words(Time.current,
                                              contest.phase_end,
                                              false,
                                              highest_measure_only: true)
        I18n.t('designer_center.milestones.fulfillment_approved.time_left', time_left: time_left)
      else
        I18n.t('designer_center.milestones.fulfillment_approved.expired')
      end
    end

  end

end
