module Navigation

  class Base
    include Rails.application.routes.url_helpers

    attr_accessor :active_tab

    def tabs
      raise NotImplementedError
    end

    def active_class(tab)
      'active' if tab == active_tab
    end

    private

    attr_reader :current_route
  end

end
