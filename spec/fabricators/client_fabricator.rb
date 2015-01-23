Fabricator(:client) do
  first_name { sequence { |i| "first_name#{ i }" } }
  last_name { sequence { |i|  "last_name#{ i }" } }
  email { sequence { |i|  "client#{ i }@example.com" } }
  password { sequence { |i|  i.to_s * 6 } }
  name_on_card { |attrs| "#{attrs[:first_name]} #{attrs[:last_name]}" }
end
