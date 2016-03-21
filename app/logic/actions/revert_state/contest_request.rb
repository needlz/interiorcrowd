module RevertState
  class ContestRequest

    STATES_FLOW = %w[draft submitted fulfillment_ready fulfillment_approved finished]

    def self.available_reverts(contest_request)
      current_state_index = STATES_FLOW.index(contest_request.status)
      return [] unless current_state_index
      STATES_FLOW[0..(current_state_index - 1)]
    end

    def initialize(contest_request)
      @contest_request = contest_request
      @contest = contest_request.contest
    end

    def revertable_to?(status)
      STATES_FLOW.index(status) < STATES_FLOW.index(contest_request.status)
    end

    def to_fulfillment_approved
      check_revertability('fulfillment_approved')
      ActiveRecord::Base.transaction do
        contest.update_attributes!(status: 'final_fulfillment')
        contest_request.update_attributes!(status: 'fulfillment_approved')
      end
    end

    def to_fulfillment_ready
      check_revertability('fulfillment_ready')
      ActiveRecord::Base.transaction do
        contest.update_attributes!(status: 'fulfillment')
        contest_request.update_attributes!(status: 'fulfillment_ready')
      end
    end

    def to_submitted
      check_revertability('submitted')
      ActiveRecord::Base.transaction do
        if %[fulfillment_ready fulfillment_approved finished].include? contest_request.status
          DesignerWinnerNotification.where(user_id: contest_request.designer.id,
                                           contest_request_id: contest_request.id).destroy_all
          DesignerLoserInfoNotification.where(contest_id: contest.id).destroy_all
        end
        contest.update_attributes!(status: 'submission')
        contest_request.update_attributes!(status: 'submitted', answer: nil)
      end
    end

    def to_draft
      check_revertability('draft')
      ActiveRecord::Base.transaction do
        if %[fulfillment_ready fulfillment_approved finished].include? contest_request.status
          DesignerWinnerNotification.where(user_id: contest_request.designer.id,
                                           contest_request_id: contest_request.id).destroy_all
          DesignerLoserInfoNotification.where(contest_id: contest.id).destroy_all
        end
        contest.update_attributes!(status: 'submission')
        contest_request.update_attributes!(status: 'draft', answer: nil)
      end
    end

    def self.revert_message(state)
      case state
        when 'draft'
          'the design to "draft" state (Not submitted) and it\'s contest to "submission" state'
        when 'submitted'
          'the design to "submitted" state (Concept board submitted) and it\'s contest to "submission" state'
        when 'fulfillment_ready'
          'the design to "fulfillment_ready" state (Create Custom Board and Product List) and it\'s contest to "fulfillment" state'
        when 'fulfillment_approved'
          'the design to "fulfillment_approved" state (Create Final Design) and it\'s contest to "final_fulfillment" state'
        else
          fail('unknown status')
      end
    end

    private

    attr_reader :contest_request, :contest

    def check_revertability(to_state)
      fail("unable to revert from '#{ contest_request.status }' to '#{ to_state }'") unless revertable_to?(to_state)
    end

  end
end
