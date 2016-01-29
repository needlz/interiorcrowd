module ActiveAdminExtensions

  module EmailDetails

    def find_recipients_by_mandrill_response(role, response)
      return unless response
      users = eval(response).map { |recipient|
        role.capitalize.constantize.find_by_email(recipient['email'])
      }
      users.compact.map{ |user|
        link_to user.name, send("admin_#{ role.downcase }_path".to_sym, user)
      }.join("<br />").html_safe
    end

  end

end
