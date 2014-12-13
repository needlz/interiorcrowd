Fabricator(:design_category) do
  name { sequence { |i| "Category#{ i }" } }
end
