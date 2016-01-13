Fabricator(:contest_request) do
  status 'submitted'
  email_thread_id { ContestRequest.generate_email_thread_id }
end

Fabricator(:draft_request, from: :contest_request) do
  status 'draft'
end

Fabricator(:closed_request, from: :contest_request) do
  status 'closed'
end
