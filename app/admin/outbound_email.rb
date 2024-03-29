include ActiveAdminExtensions::EmailDetails

ActiveAdmin.register OutboundEmail do

  index do
    selectable_column
    id_column
    column 'Template' do |email|
      template = email.template_name || UserMailer::MANDRILL_TEMPLATES.dig(email.mailer_method.to_sym, :template)
      if template
        link_to template, 'https://mandrillapp.com/code?id=' + template, target: '_blank'
      else
        email.mailer_method
      end
    end
    column 'Address' do |email|
      OutboundEmail.arguments_from_output(email.api_response).map { |email| email['email'] }.join(', ') if email.api_response
    end
    column 'Designer Name' do |email|
      recipients_list(Designer, email)
    end
    column 'Client Name' do |email|
      recipients_list(Client, email)
    end
    column 'Message' do |email|
      strip_tags(email.plain_message)
    end
    column :status
    column 'Date sent', :sent_to_mail_server_at
    actions
  end

  show do
    attributes_table do
      row 'Template' do |email|
        template = email.template_name || UserMailer::MANDRILL_TEMPLATES.dig(email.mailer_method.to_sym, :template)
        if template
          link_to template, 'https://mandrillapp.com/code?id=' + template, target: '_blank'
        else
          email.mailer_method
        end
      end
      row 'Address' do |email|
        OutboundEmail.arguments_from_output(email.api_response).map { |email| email['email'] }.join(', ') if email.api_response
      end
      row 'Designer Name' do |email|
        recipients_list(Designer, email)
      end
      row 'Client Name' do |email|
        recipients_list(Client, email)
      end
      row 'Message' do |email|
        strip_tags(email.plain_message)
      end
      row :status
      row 'Date sent', :sent_to_mail_server_at
      row :recipients
    end
  end

  action_item :become, only: :show do
    resource_name = resource.class.model_name.element
    link_to('Resend', send("resend_admin_#{ resource_name }_path", send(resource_name)), method: :get)
  end

  member_action :resend, method: :get do
    return unless current_admin_user
    email = OutboundEmail.find(params[:id])

    Jobs::Mailer.schedule(email.mailer_method, email.arguments)
    redirect_to admin_outbound_emails_path
  end

  filter :template_name, label: 'Template'
  filter :plain_message, label: 'Message'
  filter :sent_to_mail_server_at, label: 'Date Sent'
  filter :by_user_name_in, as: :string, label: 'Recipient Name'

end
