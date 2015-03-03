Fabricator(:concept_board_comment) do
  text 'a comment'
end

Fabricator(:concept_board_client_comment, from: :concept_board_comment) do
  text 'a comment'
  role 'Client'
end

Fabricator(:concept_board_designer_comment, from: :concept_board_comment) do
  text 'a comment'
  role 'Designer'
end
