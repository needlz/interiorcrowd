Fabricator(:reviewer_invitation) do
  username { sequence { |i| "user#{ i }" } }
  email { sequence { |i| "user#{ i }@example.com" } }
end
