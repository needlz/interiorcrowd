class Showcase

  class DummyLookbookItem

    attr_reader :image

    def initialize(image)
      @image = image
    end

    def id
      nil
    end

  end

  attr_reader :items, :editable, :placeholder_src, :single

  def initialize(options)
    @items = options[:items]
    @images = options[:images]
    if @items
      @items = @items.includes(:image)
    else
      @items = @images.map { |image| DummyLookbookItem.new(image) } unless @items
    end
    @editable = options[:editable]
    @placeholder_src = options[:placeholder_src] || '/assets/img-content.png'
    @single = options[:single]
  end

end
