Fabricator(:contest) do; end

Fabricator(:completed_contest, from: :contest) do
  Fabricate.sequence do |i|
    project_name "contest#{ i }"
  end

  design_category
  design_spaces { Fabricate.times(2, :design_space) }
  budget_plan 1
  space_budget '$1000'
  desirable_colors '#fff, #ccc'
  appeals { Fabricate.times(1, :appeal) }
  designer_level_id 1

  preferred_retailers
end

Fabricator(:contest_in_submission, from: :completed_contest) do
  status 'submission'
end

Fabricator(:contest_during_winner_selection, from: :completed_contest) do
  status 'winner_selection'
end

Fabricator(:contest_during_fulfillment, from: :completed_contest) do
  status 'fulfillment'
end

Fabricator(:contest_during_final_fulfillment, from: :completed_contest) do
  status 'final_fulfillment'
end
