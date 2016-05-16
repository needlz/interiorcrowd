module Navigation

  class Base
    include Rails.application.routes.url_helpers

    attr_accessor :active_tab

    def initialize(active_tab = nil)
      @active_tab = active_tab
    end

    def tabs
      raise NotImplementedError
    end

    def active_class(tab, css_class = 'item-sel')
      css_class if tab == active_tab
    end

    def to_mobile_menu
      tabs.inject({}){ |items, (tab, navigation_link)| items[navigation_link[:name]] = navigation_link[:href]; items }
    end

    private

    attr_reader :current_route
  end

end
