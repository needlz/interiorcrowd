Fabricator(:realtor_contact) do
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  brokerage { Faker::Company.name }
  email { Faker::Internet.email }
  phone { Faker::PhoneNumber.phone_number }
  choice 'email_me'
end
