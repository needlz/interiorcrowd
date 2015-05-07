ActiveAdmin.register Sound do

  form do |f|
    f.inputs
    f.inputs 'Sound Details' do
      f.input :audio, :required => false, :as => :file
    end
    f.actions
  end

end
