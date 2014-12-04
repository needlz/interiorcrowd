Fabricator(:designer) do
  first_name{ sequence { |i| "first_name#{ i }" } }
  last_name{ sequence { |i| "last_name#{ i }" } }
  email{ sequence { |i| "designer#{ i }@example.com" } }
  password{ sequence { |i| i.to_s * 6 } }
end
