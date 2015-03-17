class DesignerResponsesQuery

  def initialize(designer, filter = nil)
    @designer = designer
    @filter = filter
  end

  def current_responses
    designer.requests_by_status(filter).with_design_properties.includes(contest: [:client])
  end

  def completed_responses
    designer.requests_by_status(['finished', 'closed']).with_design_properties.includes(contest: [:client])
  end

  private

  attr_reader :designer, :filter

end