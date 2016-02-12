Fabricator(:contest) do
  Fabricate.sequence do |i|
    project_name "contest#{ i }"
    design_category
    design_spaces { Fabricate.times(2, :design_space) }
    budget_plan 1
    location_zip '00001'
  end
  preferred_retailers
end

Fabricator(:contest_in_submission, from: :contest) do
  status 'submission'
end

Fabricator(:contest_during_winner_selection, from: :contest) do
  status 'winner_selection'
end
