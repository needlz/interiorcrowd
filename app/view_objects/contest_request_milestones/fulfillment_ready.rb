module ContestRequestMilestones

  class FulfillmentReady < Base

    def designer_hint
      if in_progress?
        I18n.t('designer_center.milestones.fulfillment_ready.time_left', time_left: time_left)
      else
        I18n.t('designer_center.milestones.fulfillment_ready.expired')
      end
    end

  end

end
