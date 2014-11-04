class LookbookView

  attr_reader :ids, :paths, :titles, :links, :link_titles, :feedback

  def initialize(image_ids, image_paths, image_titles, links, link_titles, feedback)
    @ids = image_ids || []
    @paths = image_paths || []
    @titles = image_titles || []
    @links = links || []
    @link_titles = link_titles || []
    @feedback = feedback || ''
  end

  def serialized_paths
    paths.join(',')
  end

  def serialized_ids
    ids.join(',')
  end

end