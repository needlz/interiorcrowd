ActiveAdmin.register Contest do

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
