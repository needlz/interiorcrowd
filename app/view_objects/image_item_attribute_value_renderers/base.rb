module ImageItemAttributeValueRenderers

  class Base

    def self.create(image_item, attribute, view_context)
      klass =
        begin
          "ImageItemAttributeValueRenderers::#{ attribute.to_s.camelize }".constantize
        rescue
          ImageItemAttributeValueRenderers::Base
        end
      klass.new(image_item, attribute, view_context)
    end

    def initialize(image_item, attribute, view_context)
      @image_item = image_item
      @attribute = attribute
      @view_context = view_context
    end

    def to_s
      value.to_s
    end

    private

    attr_reader :image_item, :attribute, :view_context

    def value
      image_item.send(attribute)
    end

  end

end
