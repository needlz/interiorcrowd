class LookbookView

  attr_reader :ids, :paths, :titles, :links, :link_titles, :feedback

  def initialize(options)
    if options
      if options.kind_of?(Hash)
        @paths = options['picture']['urls']
        @ids = options['picture']['ids']
        @titles = options['picture']['titles']

        @links = options['link']['urls']
        @link_titles = options['link']['titles']

        @feedback = options['feedback']
      else
        lookbook = options
        pictures = lookbook.lookbook_details.includes(:image).uploaded_pictures.order(id: :asc)
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
        links = lookbook.lookbook_details.external_pictures.order(id: :asc)
        @links = links.pluck(:url)
        @link_titles = links.pluck(:description)
        @feedback = lookbook.feedback
      end
    else
      @ids = []
      @paths = []
      @titles = []
      @links = []
      @link_titles = []
      @feedback = ''  
    end
  end

  def serialized_paths
    paths.join(',')
  end

  def serialized_ids
    ids.join(',')
  end

end