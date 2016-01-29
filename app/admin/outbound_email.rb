include ActiveAdminExtensions::EmailDetails

ActiveAdmin.register OutboundEmail do

  index do
    selectable_column
    id_column
    column 'Template' do |email|
      template = email.template_name || UserMailer::MANDRILL_TEMPLATES[email.mailer_method.to_sym]
      link_to template, 'https://mandrillapp.com/templates?q=' + template, target: '_blank'
    end
    column 'Designer Name' do |email|
      find_recipients_by_mandrill_response('Designer', email.api_response)
    end
    column 'Client Name' do |email|
      find_recipients_by_mandrill_response('Client', email.api_response)
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
        template = email.template_name || UserMailer::MANDRILL_TEMPLATES[email.mailer_method.to_sym]
        link_to template, 'https://mandrillapp.com/templates?q=' + template, target: '_blank'
      end
      row 'Designer Name' do |email|
        find_recipients_by_mandrill_response('Designer', email.api_response)
      end
      row 'Client Name' do |email|
        find_recipients_by_mandrill_response('Client', email.api_response)
      end
      row 'Message' do |email|
        strip_tags(email.plain_message)
      end
      row :status
      row 'Date sent', :sent_to_mail_server_at
    end
  end

  action_item :become, only: :show do
    resource_name = resource.class.model_name.element
    link_to('Resend', send("resend_admin_#{ resource_name }_path", send(resource_name)), method: :get)
  end

  member_action :resend, method: :get do
    resource_name = resource.class.model_name.element
    email = OutboundEmail.find(params[:id])
    return unless current_admin_user

    args = eval(email.mail_args.gsub(/\#\<(\w+) id: (\d+)[^\>]+\>/, '\1.find(\2)'))

    Jobs::Mailer.schedule(email.mailer_method, args)
    redirect_to admin_outbound_emails_path
  end

  filter :template_name, label: 'Template'
  filter :plain_message, label: 'Message'
  filter :sent_to_mail_server_at, label: 'Date Sent'
  filter :by_user_name_in, as: :string, label: 'Recipient Name'

end
