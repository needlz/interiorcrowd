Fabricator(:client) do
  first_name { sequence { |i| "first_name#{ i }" } }
  last_name { sequence { |i|  "last_name#{ i }" } }
  email { sequence { |i|  "client#{ i }@example.com" } }
  password { Client.encrypt('password') }
  name_on_card { |attrs| "#{attrs[:first_name]} #{attrs[:last_name]}" }
  # stripe_customer_id { |i| "id#{ i }"}
end
