Fabricator(:product_item) do
  text 'description'
  name { sequence { |i| "product item #{ i }" } }
end
