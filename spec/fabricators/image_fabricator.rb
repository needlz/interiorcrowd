Fabricator(:image) do

end

Fabricator(:example_image, from: :image) do
  kind Image::LIKED_EXAMPLE
end

Fabricator(:space_image, from: :image) do
  kind Image::SPACE
end

