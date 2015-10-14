Fabricator(:appeal) do
  name { sequence { |i|  "Style #{ i }" } }
end
