class DesignerLookbook

  attr_reader :ids, :paths, :titles, :links, :link_titles, :feedback

  def initialize(options)
    if options
      if options.kind_of?(Hash)
        initialize_from_hash(options)
      else
        initialize_from_object(options)
      end
    else
      initialize_defaults
    end
  end

  def serialized_paths
    paths.join(',')
  end

  def serialized_ids
    ids.join(',')
  end

  private

  def initialize_from_hash(options)
    @paths = options['picture']['urls']
    @ids = options['picture']['ids']
    @titles = options['picture']['titles']

    @links = options['link']['urls']
    @link_titles = options['link']['titles']

    @feedback = options['feedback']
  end

  def initialize_from_object(options)
    pictures = options.lookbook_details.includes(:image).uploaded_pictures.order(id: :asc)
    if pictures.present?
      @ids = []
      @paths = []
      @titles = []
      pictures.each do |lookbook_document|
        image = lookbook_document.image
        @paths << image.image.url(:medium)
        @ids << image.id
        @titles << lookbook_document.description
      end
    end
    links = options.lookbook_details.external_pictures.order(id: :asc)
    @links = links.pluck(:url)
    @link_titles = links.pluck(:description)
    @feedback = options.feedback
  end

  def initialize_defaults
    @ids = []
    @paths = []
    @titles = []
    @links = []
    @link_titles = []
    @feedback = ''
  end

end