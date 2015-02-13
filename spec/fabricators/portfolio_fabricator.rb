Fabricator(:portfolio) do
  designer
  path { sequence { |i| "path#{ i }" } }
  years_of_experience 2
end
