Fabricator(:credit_card) do
  name_on_card 'Name Surname'
  ex_month 5
  ex_year 2018
  zip{ sequence { |i| 10000 + i } }
  cvc 123
  card_type 'visa'
  last_4_digits '1111'
  stripe_id { sequence { |i| i.to_s } }
end
