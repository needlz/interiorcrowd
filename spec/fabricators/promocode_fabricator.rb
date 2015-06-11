Fabricator(:promocode) do
  token Promocode.generate_token
end
