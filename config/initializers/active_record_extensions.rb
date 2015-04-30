module ActiveRecord
  class Base

    def changed_to?(attribute, value)
      send("#{ attribute.to_s }_changed?") && (send(attribute) == value)
    end

  end
end

class Object
  def to_bool
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(self)
  end
end
