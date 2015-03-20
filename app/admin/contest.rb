ActiveAdmin.register Contest do


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

  controller do
    def scoped_collection
      super.includes :client
    end
  end

  index do
    column :id
    column :project_name
    column :status
    column :client
    actions
  end

  filter :status, as: :check_boxes, collection: proc { Contest::STATUSES }

  scope 'All', :all
  scope 'Active', :active
  scope 'Inactive', :inactive

end
