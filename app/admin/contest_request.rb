ActiveAdmin.register ContestRequest do
  menu priority: 9

  index do
    column :id
    column :feedback
    column :status do |request|
      "#{ request.status.to_s } (#{ ContestResponseView.status_name(request.status) })"
    end
    column :answer
    column :final_note
    column :pull_together_note
    column :token
    column :created_at
    column :updated_at
    actions
  end

end
