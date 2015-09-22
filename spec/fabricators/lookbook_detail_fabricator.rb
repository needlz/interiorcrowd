Fabricator(:lookbook_detail) do

end

Fabricator(:lookbook_image, from: :lookbook_detail) do
  image
end
