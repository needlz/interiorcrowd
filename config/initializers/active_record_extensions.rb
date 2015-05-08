module ActiveRecord
  class Base

    def changed_to?(attribute, value)
      send("#{ attribute.to_s }_changed?") && (send(attribute) == value)
    end

  end
end

class Object
  def to_bool
    ActiveRecord::Type::Boolean.new.type_cast_from_database(self)
  end
end
