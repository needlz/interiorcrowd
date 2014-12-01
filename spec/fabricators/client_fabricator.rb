Fabricator(:client) do
  Fabricate.sequence do |i|
    first_name "first_name#{ i }"
    last_name "last_name#{ i }"
    email "cleint#{ i }@example.com"
    password i.to_s * 6
  end
  name_on_card { |attrs| "#{attrs[:first_name]} #{attrs[:last_name]}" }
end
