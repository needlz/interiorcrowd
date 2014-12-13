Fabricator(:design_space) do
  name { sequence { |i| "Room#{ i }" } }
end
