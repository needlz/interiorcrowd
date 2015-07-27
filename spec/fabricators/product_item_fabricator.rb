Fabricator(:image_item) do
  text 'description'
  phase 'collaboration'
  name { sequence { |i| "product item #{ i }" } }
end

Fabricator(:product_item, from: :image_item) do
  kind 'product_items'
end
