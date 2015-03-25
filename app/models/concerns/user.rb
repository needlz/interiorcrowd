module User
  extend ActiveSupport::Concern

  include UserPolicies

  def name
    "#{ first_name } #{ last_name }"
  end

  def role
    self.class.name
  end

  def designer?
    kind_of?(Designer)
  end

  def client?
    kind_of?(Client)
  end

  def beta?
    session[:beta]
  end
end
