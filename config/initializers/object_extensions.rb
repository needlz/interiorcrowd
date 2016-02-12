class Object

  def to_bool
    ActiveRecord::Type::Boolean.new.type_cast_from_database(self)
  end

end
