class ContestPhases

  def self.status_to_index(status)
    STATUSES_TO_INDICES[status]
  end

  def self.indices
    INDICES_TO_PHASES.keys
  end

  def self.index_to_phase(index)
    INDICES_TO_PHASES[index]
  end

  private

  STATUSES_TO_INDICES = {
      'draft' => 0,
      'submitted' => 0,
      'fulfillment' => 1,
      'fulfillment_ready' => 1,
      'fulfillment_approved' => 2,
      'finished' => 2,
      'closed' => 0,
  }

  INDICES_TO_PHASES = {
      0 => :initial,
      1 => :product_list,
      2 => :final_design
  }

end
