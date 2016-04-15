Fabricator(:client) do
  first_name { sequence { |i| "first_name#{ i }" } }
  last_name { sequence { |i|  "last_name#{ i }" } }
  email { sequence { |i|  "client#{ i }@example.com" } }
  plain_password 'password'
  designer_level

  before_create { |client| client.password = Client.encrypt(plain_password) }
end

Fabricator(:client_with_primary_card, from: :client) do
  after_create { |client| client.update_attributes(primary_card_id: Fabricate(:credit_card, client: client).id) }
end
