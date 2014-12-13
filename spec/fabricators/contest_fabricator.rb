Fabricator(:contest) do
  Fabricate.sequence do |i|
    project_name "contest#{ i }"
    design_category
    design_space
    budget_plan 1
  end
end
