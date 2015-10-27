class PhaseUpdater

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def monitor_phase_change(&block)
    return block.call unless contest_request.lookbook
    old_status = contest_request.status
    block.call
    new_status = contest_request.status
    old_phase = ContestPhases.status_to_phase(old_status)
    new_phase = ContestPhases.status_to_phase(new_status)
    if (old_status != new_status) && (old_phase != new_phase)
      copy_lookbook_items(old_phase, new_phase)
    end
  end

  private

  attr_reader :contest_request

  def copy_lookbook_items(old_phase, phase)
    contest_request.lookbook_items_by_phase(old_phase).each do |item|
      attributes = { image_id: item.image_id, description: item.description }
      contest_request.lookbook.lookbook_details.create!(attributes.merge(phase: phase.to_s))
    end
  end

end
