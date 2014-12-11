Fabricator(:portfolio) do
  designer
  path { sequence { |i| "path#{ i }" } }
  years_of_expirience 2
end
