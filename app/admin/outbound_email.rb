ActiveAdmin.register OutboundEmail do

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

end
