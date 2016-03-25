class ApproveFulfillment < Action

  attr_reader :approved

  def initialize(contest_request)
    @contest_request = contest_request
    @approved = false
  end

  def perform
    contest_request.with_lock do
      ensure_correct_status
      DesignerInfoNotification.create(user_id: contest_request.designer_id,
                                      contest_id: contest_request.contest_id,
                                      contest_request_id: contest_request.id)
      update_status

      finalize_image_items

      send_notifications
    end
    @approved = true
  end

  private

  attr_reader :contest_request

  def ensure_correct_status
    raise ArgumentError.new('expected contest request to be "fulfillment_ready"') unless contest_request.fulfillment_ready?
  end

  def update_status
    PhaseUpdater.new(contest_request).monitor_phase_change do
      contest_request.approve_fulfillment!
      contest_request.contest.final!
    end
  end

  def finalize_image_items
    copyist = ActiveRecordStampCreator.new(
        records: contest_request.image_items.published.non_disliked,
        new_attributes: { phase: 'final_design',
                          temporary_version_id: nil }
    )
    copyist.perform do |copy|
      copy.save!
    end
  end

  def send_notifications
    Jobs::Mailer.schedule(:client_ready_for_final_design, [contest_request.id])
    Jobs::Mailer.schedule(:client_moved_to_final_design, [contest_request.contest_id])
  end

end
