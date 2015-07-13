class LookbookDetailCreation

  def initialize(contest_request, lookbook_detail_attributes)
    @contest_request = contest_request
    @lookbook_detail_attributes = lookbook_detail_attributes
  end

  def perform
    items = contest_request.lookbook.lookbook_details
    new_item_attributes = lookbook_detail_attributes.
      merge(phase: ContestPhases.status_to_phase(contest_request.status))
    items.create!(new_item_attributes)
  end

  private

  attr_reader :contest_request, :lookbook_detail_attributes

end
