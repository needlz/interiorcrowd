ActiveAdmin.register ContestRequest do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

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
  end

end
