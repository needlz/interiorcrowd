module Navigation

  class Base

    def initialize(view_context)
      @view_context = view_context
    end

    def tabs
      fail 'abstract method'
    end

    def active_class(tab_routes)
      'active' if tab_routes.find{ |route| route == current_route }
    end

    private

    attr_reader :view_context

    def current_route
      { controller: view_context.controller_name, action: view_context.action_name }
    end
  end

end
