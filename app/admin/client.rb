ActiveAdmin.register Client do

  form do |f|
    f.inputs
    f.inputs 'Stripe details' do
      f.input :stripe_customer_id
    end
    f.actions
  end

end
