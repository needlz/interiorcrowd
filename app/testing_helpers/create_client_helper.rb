class CreateClientHelper < TestHelperBase

  def initialize(controller, session)
    @controller = controller
    @session = session
  end

  def create_with_contest
    client_attributes = Fabricate.attributes_for(:client, email: Faker::Internet.email)
    client_attributes[:password] = Client.encrypt(client_attributes[:plain_password])
    client = Client.create!(client_attributes)
    contest = Fabricate(:contest_in_submission, client: client, design_category: DesignCategory.last, design_spaces: [DesignSpace.last])
    Authenticator.sign_in(client, session)
    controller.redirect_to(controller.client_center_entries_path)
  end

  def create_with_live_contest
    client_attributes = Fabricate.attributes_for(:client, email: Faker::Internet.email)
    client_attributes[:password] = Client.encrypt(client_attributes[:plain_password])
    client = Client.create!(client_attributes)
    contest = Fabricate(:contest_in_submission, client: client, design_category: DesignCategory.last, design_spaces: [DesignSpace.last], appeals: [])
    credit_card = CreditCard.create!(Fabricate.attributes_for(:credit_card, client: client))
    client.update_attributes!(primary_card_id: credit_card.id)
    ClientPayment.create!(client_id: client.id, contest_id: contest.id)
    Authenticator.sign_in(client, session)
    controller.redirect_to(controller.client_center_entries_path)
  end

  private

  attr_reader :session, :controller

end
