ActiveAdmin.register Client do


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

  form do |f|
    f.inputs do
      f.input :id
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :name_on_card
      f.input :card_type
      f.input :address
      f.input :state
      f.input :zip
      f.input :card_number
      f.input :card_ex_month
      f.input :card_ex_year
      f.input :card_cvc
      f.input :status
      f.input :city
      f.input :phone_number
      f.input :billing_address
      f.input :billing_state
      f.input :billing_city
      f.input :plain_password
      f.input :roles_mask, :as => :check_boxes, label: 'Role', :collection => [['Test', 1]] #TODO value is not saved, fix it
      f.input :created_at
      f.input :updated_at
    end
    f.actions
  end

end
