Fabricator(:contest) do
  Fabricate.sequence do |i|
    project_name "contest#{ i }"
    design_category
    design_space
    budget_plan 1
  end
  preferred_retailers
end

Fabricator(:contest_in_submission, from: :contest) do
  status 'submission'
end
