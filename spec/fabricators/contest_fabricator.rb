Fabricator(:contest) do
  client
  Fabricate.sequence do |i|
    project_name "contest#{ i }"
  end
end
