Fabricator(:contest_request) do
  status 'submitted'
end

Fabricator(:draft_request, from: :contest_request) do
  status 'draft'
end

Fabricator(:closed_request, from: :contest_request) do
  status 'closed'
end
