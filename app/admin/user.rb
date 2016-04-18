ActiveAdmin.register Client, as: "User" do

  fields = [
      ['Client Name', :name],
      ['Email', :email],
      ['Plain Password', :plain_password],
      ['Phone Number', :phone_number],
      ['Project Name', ->(user) { user.last_contest.project_name if user.last_contest }],
      ['Project Status', ->(user) { last_contest_status(user) }],
      ['Date Created', :created_at]
  ]

  show do
    attributes_table do
      fields.each do |field_name, method|
        row field_name do |user|
          case method
            when Symbol
              user.send(method)
            when Proc
              method.call(user)
            else
              ''
          end
        end
      end
    end
  end

  index do
    selectable_column
    id_column
    fields.each do |args|
      column *args
    end
    actions
  end

  csv do
    column :id
    fields.each do |args|
      block = args[1]
      column args[0], {}, &block
    end
  end

  action_item :become, only: :show do
    resource_name = 'user'
    link_to('Log in', send("become_admin_#{ resource_name }_path", send(resource_name)), method: :get)
  end

  member_action :become, method: :get do
    return unless current_admin_user
    session["client_id".to_sym] = params[:id]
    redirect_to send("client_center_path")
  end

end
