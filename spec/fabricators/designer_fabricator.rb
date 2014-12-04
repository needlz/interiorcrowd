Fabricator(:designer) do
  Fabricate.sequence do |i|
    first_name "first_name#{ i }"
    last_name "last_name#{ i }"
    email "designer#{ i }@example.com"
    password i.to_s * 6
  end
end
