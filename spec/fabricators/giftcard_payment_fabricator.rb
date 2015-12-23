Fabricator(:giftcard_payment) do
  email { sequence { |i| "email#{ i }@example.com" } }
  quantity 5
  price_cents 300
end
