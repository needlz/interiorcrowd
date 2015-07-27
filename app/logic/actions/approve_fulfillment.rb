class ApproveFulfillment

  attr_reader :approved

  def initialize(contest_request)
    @contest_request = contest_request
    @approved = false
  end

  def perform
    return false if contest_request.fulfillment_approved?
    ActiveRecord::Base.transaction do
      DesignerInfoNotification.create(user_id: contest_request.designer_id,
                                      contest_id: contest_request.contest_id,
                                      contest_request_id: contest_request.id)

      PhaseUpdater.new(contest_request).monitor_phase_change do
        contest_request.approve_fulfillment!
      end

      finalize_image_items

      Jobs::Mailer.schedule(:client_ready_for_final_design, [contest_request])
    end
    @approved = true
  end

  private

  attr_reader :contest_request

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

end
