module ActiveAdminExtensions

  module User

    def extend_user
      login_actions
      ignore_password
    end

    def login_actions
      action_item :become, only: :show do
        resource_name = resource.class.model_name.element
        link_to('Log in', send("become_admin_#{ resource_name }_path", send(resource_name)), method: :get)
      end

      member_action :become, method: :get do
        resource_name = resource.class.model_name.element
        user = resource_name.capitalize.constantize.find(params[:id])
        return unless current_admin_user
        session["#{ user.class.name.downcase }_id".to_sym] = params[:id]
        redirect_to send("#{ resource_name }_center_path")
      end
    end

    def ignore_password
      controller do

        def update
          resource_name = resource.class.model_name.element
          if params[resource_name][:plain_password].present?
            params[resource_name][:password] = resource.class.encrypt(params[resource_name][:plain_password])
          else
            params[resource_name].delete(:password)
            params[resource_name].delete(:plain_password)
          end
          super
        end

      end
    end

  end

end


