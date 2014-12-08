Fabricator(:portfolio) do
  designer
  path { sequence { |i| "path#{ i }" } }
end
