Fabricator(:lookbook) do
  lookbook_details { [Fabricate(:lookbook_image, phase: 'initial')] }
end
