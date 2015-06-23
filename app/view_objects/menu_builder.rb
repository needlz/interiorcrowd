class MenuBuilder

  class MenuItem

    def initialize(name, href_or_children)
      @name = name
      if href_or_children.kind_of?(Hash)
        set_children href_or_children.map{ |child_name, content| MenuItem.new(child_name, content) }
      elsif href_or_children.kind_of?(Navigation::Base)
        set_children href_or_children.tabs.map{ |tab, navigation_link| MenuItem.new(navigation_link[:name], navigation_link[:href]) }
      else
        @href = href_or_children
      end
    end

    attr_reader :name, :href, :children, :identifier

    private

    def set_children(children)
      @children = children
      @identifier = @name.parameterize.underscore
    end

  end

  def initialize(links)
    @items = []
    append(links)
  end

  def append(links)
    items_to_append = links.map{ |name, content| MenuItem.new(name, content) }
    @items.concat(items_to_append)
  end

  def parent_items
    items
  end

  attr_reader :items

end
