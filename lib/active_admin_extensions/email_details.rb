module ActiveAdminExtensions

  module EmailDetails

    def recipients_list(user_class, email)
      find_among_recipients(user_class.name, email.recipients) || find_recipients_by_mandrill_response(user_class, email)
    end

    def find_among_recipients(role, response)
      return unless response
      response = JSON.parse(response)
      response.select{ |user| user['role'] == role }.map{ |user|
        user = role.constantize.find_by_email(user['email'])
        link_to user.name, send("admin_#{ role.downcase }_path".to_sym, user.id) if user
      }.compact.join("<br />").html_safe || ''
    end

    def users_by_mandrill_response(role, response)
      eval(response).map { |recipient|
        role.find_by_email(recipient['email'])
      }.compact
    end

    def find_recipients_by_mandrill_response(role, email)
      recipient_roles = UserMailer::MANDRILL_TEMPLATES.dig(email.mailer_method.to_sym, :description, :recipients_roles)
      return unless (recipient_roles && recipient_roles.include?(role) && email.api_response)
      users = users_by_mandrill_response(role, email.api_response)

      users.map{ |user|
        link_to user.name, send("admin_#{ role.name.downcase }_path".to_sym, user)
      }.join("<br />").html_safe
    end

  end

end
