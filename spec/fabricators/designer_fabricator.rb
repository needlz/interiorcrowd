Fabricator(:designer) do
  first_name { sequence { |i| "first_name#{ i }" } }
  last_name { sequence { |i| "last_name#{ i }" } }
  email { sequence { |i| "designer#{ i }@example.com" } }
  plain_password 'password'

  before_create { |designer| designer.password = Designer.encrypt(plain_password) }
end

Fabricator(:designer_with_portfolio, from: :designer) do
  portfolio
end
