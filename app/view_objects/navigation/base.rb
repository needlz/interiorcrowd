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

    def active_class(tab)
      'item-sel' if tab == active_tab
    end

    private

    attr_reader :current_route
  end

end
