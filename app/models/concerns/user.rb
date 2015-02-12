module User
  extend ActiveSupport::Concern

  def name
    "#{ first_name } #{ last_name }"
  end

  def role
    self.class.name
  end
end