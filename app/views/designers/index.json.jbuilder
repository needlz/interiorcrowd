json.array!(@designers) do |designer|
  json.extract! designer, :id
  json.url designer_url(designer, format: :json)
end
