ActiveAdmin.register Client, as: "User" do
  menu priority: 5

  index do
    selectable_column
    id_column
    column 'Client Name' do |user|
      user.name
    end
    column 'Email', :email
    column 'Plain Password', :plain_password
    column 'Project Name' do |user|
      user.last_contest.project_name if user.last_contest
    end
    column 'Project Status' do |user|
      last_contest_status(user)
    end
    column 'Date Created', :created_at
    actions
  end

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
end
