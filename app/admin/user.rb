ActiveAdmin.register Client, as: "User" do

  show do
    attributes_table do
      row 'Client Name' do |user|
        user.name
      end
      row 'Email' do |user|
        user.email
      end
      row 'Plain Password' do |user|
        user.plain_password
      end
      row 'Project Name' do |user|
        user.last_contest.project_name if user.last_contest
      end
      row 'Project Status' do |user|
        last_contest_status(user)
      end
      row 'Date Created' do |user|
        user.created_at
      end
    end
  end

  columns = [
    ['Client Name', ->(user) { user.name }],
    ['Email', :email],
    ['Plain Password', :plain_password],
    ['Project Name', ->(user) { user.last_contest.project_name if user.last_contest }],
    ['Project Status', ->(user) { last_contest_status(user) }],
    ['Date Created', :created_at]
  ]

  index do
    selectable_column
    id_column
    columns.each do |args|
      column *args
    end
    actions
  end

  csv do
    column :id
    columns.each do |args|
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
