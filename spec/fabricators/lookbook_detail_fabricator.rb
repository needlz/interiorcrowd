Fabricator(:lookbook_detail) do

end

Fabricator(:lookbook_url, from: :lookbook_detail) do
  doc_type LookbookDetail::EXTERNAL_PICTURE_TYPE
  url 'http://example.com/example.jpg'
end

Fabricator(:lookbook_image, from: :lookbook_detail) do
  doc_type LookbookDetail::UPLOADED_PICTURE_TYPE
  image
end
