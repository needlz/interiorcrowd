class CreateDesignerHelper < TestHelperBase

  def self.path(view_context, params)
    view_context.development_scenario_path({ scenario_class: name }.merge(params))
  end

  def create
    designer_attributes = Fabricate.attributes_for(:designer, email: Faker::Internet.email)
    designer_attributes[:password] = Designer.encrypt(designer_attributes[:plain_password])
    designer = Designer.create!(designer_attributes)
    Portfolio.create!(designer_id: designer.id)
    Authenticator.sign_in(designer, session)
    controller.redirect_to(controller.designer_center_path)
  end

  private

  attr_reader :session, :controller

end
