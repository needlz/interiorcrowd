Fabricator(:admin_user) do
  email { sequence { |i|  "client#{ i }@example.com" } }
  password 'password'
  password_confirmation 'password'
end
