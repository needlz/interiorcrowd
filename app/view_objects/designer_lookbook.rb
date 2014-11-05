class DesignerLookbook

  attr_reader :ids, :paths, :titles, :links, :link_titles, :feedback

  def initialize(options)
    if options
      if options.kind_of?(Hash)
        initialize_from_options(options)
      else
        initialize_from_lookbook(options)
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

  def initialize_from_options(options)
    initialize_defaults
    if options['picture']
      @ids = options['picture']['ids']
      @paths = options['picture']['urls']
      @titles = options['picture']['titles']
    end
    if options['link']
      @links = options['link']['urls']
      @link_titles = options['link']['titles']
    end
    @feedback = options['feedback']
  end

  def initialize_from_lookbook(lookbook)
    lookbook_items= lookbook.lookbook_details.includes(:image).uploaded_pictures.order(id: :asc)
    if lookbook_items.present?
      @ids = []
      @paths = []
      @titles = []
      lookbook_items.each do |item|
        image = item.image
        @ids << image.id
        @paths << image.image.url(:medium)
        @titles << item.description
      end
    end
    links = lookbook.lookbook_details.external_pictures.order(id: :asc)

    @links = links.pluck(:url)
    @link_titles = links.pluck(:description)

    @feedback = lookbook.feedback
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