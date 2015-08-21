module ContestRequestMilestones

  class FulfillmentApproved < Base

    def designer_hint
      if in_progress?
        I18n.t('designer_center.milestones.fulfillment_approved.time_left', time_left: time_left)
      else
        I18n.t('designer_center.milestones.fulfillment_approved.expired')
      end
    end

  end

end
