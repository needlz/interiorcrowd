ActiveAdmin.register CreditCard do
  menu priority: 10

  form do |f|
    f.inputs
    f.inputs 'Stripe details' do
      # for some reason the field is not shown by default
      f.input :stripe_id
    end
    f.actions
  end

end
