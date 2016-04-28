module Breadcrumbs

  class Base < Array

    def initialize(urls_helper)
      @urls_helper = urls_helper
    end

    def <<(element)
      super
      prepend_arrow if prepend_arrow?
      self
    end

    private

    attr_reader :urls_helper

    def prepend_arrow?
      length == 1 && !starts_with_arrow?
    end

    def starts_with_arrow?
      first_name.present? && first_name[0] == '<'
    end

    def prepend_arrow
      first_name.prepend('< ')
    end

    def first_name
      self[0][:name]
    end

  end

end
