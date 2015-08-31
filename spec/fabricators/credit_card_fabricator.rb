Fabricator(:credit_card) do
  name_on_card 'Name Surname'
  ex_month 5
  ex_year 2018
  zip{ sequence { |i| 10000 + i } }
  number{ sequence { |i| (4242424242424242 + i).to_s } }
  cvc 123
  card_type 'visa'
end
