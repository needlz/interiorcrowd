require "rails_helper"

RSpec.describe DesignerResponsesQuery do

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }

  let!(:submitted_request) do Fabricate(:contest_request,
                                       designer: designer,
                                       contest: Fabricate(:contest,
                                                          client: client,
                                                          desirable_colors: '955e3a,ffb81b',
                                                          undesirable_colors: 'EEE',
                                                          status: 'submission'),
                                       status: 'submitted',
                                       lookbook: Fabricate(:lookbook))
  end
  let!(:finished_request) do Fabricate(:contest_request,
                                      designer: designer,
                                      contest: Fabricate(:contest,
                                                         client: client,
                                                         desirable_colors: '955e3a,ffb81b',
                                                         undesirable_colors: 'EEE',
                                                         status: 'submission'),
                                      status: 'finished',
                                      lookbook: Fabricate(:lookbook))
  end
  let!(:closed_request) do Fabricate(:contest_request,
                                    designer: designer,
                                    contest: Fabricate(:contest,
                                                       client: client,
                                                       desirable_colors: '955e3a,ffb81b',
                                                       undesirable_colors: 'EEE',
                                                       status: 'submission'),
                                    status: 'closed',
                                    lookbook: Fabricate(:lookbook))
  end
  let!(:draft_request) { Fabricate(:contest_request, designer: designer,
                                   contest: Fabricate(:contest,
                                                      client: client,
                                                      desirable_colors: '955e3a,ffb81b',
                                                      undesirable_colors: 'EEE',
                                                      status: 'submission'),
                                   status: 'draft') }

  let(:responses_query) { DesignerResponsesQuery.new(designer) }

  it 'returns list of current responses' do
    expect(responses_query.current_responses).to match_array [submitted_request, draft_request]
  end

  it 'returns list of completed responses' do
    expect(responses_query.completed_responses).to match_array [finished_request, closed_request]
  end

end
