class PhaseUpdater

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform_phase_change(&block)
    return block.call unless contest_request.lookbook
    old_status = contest_request.status
    block.call
    new_status = contest_request.status
    old_phase = ContestPhases.status_to_phase(old_status)
    new_phase = ContestPhases.status_to_phase(new_status)
    if (old_status != new_status) && (old_phase != new_phase)
      perform(new_phase)
    end
  end

  private

  attr_reader :contest_request

  def perform(phase)
    last_lookbook_item = contest_request.current_lookbook_item
    return unless last_lookbook_item
    items_scope = contest_request.lookbook.lookbook_details
    item = items_scope.find_by_phase(phase.to_s)
    attributes = { lookbook_id: last_lookbook_item.lookbook_id,
        image_id: last_lookbook_item.image_id,
        doc_type: last_lookbook_item.doc_type,
        description: last_lookbook_item.description }
    if item
      item.update_attributes!(attributes)
    else
      items_scope.create!(attributes.merge(phase: phase.to_s))
    end
  end

end
