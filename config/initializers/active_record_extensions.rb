module ActiveRecord
  class Base

    def changed_to?(attribute, value)
      send("#{ attribute.to_s }_changed?") && (send(attribute) == value)
    end

  end
end
