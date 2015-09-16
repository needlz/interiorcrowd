module ActiveAdminExtensions

  module UserController

    def update
      resource_name = resource.class.model_name.element
      if params[resource_name][:password].blank?
        params[resource_name].delete('password')
        params[resource_name].delete('password_confirmation')
      end
      super
    end

  end

end
