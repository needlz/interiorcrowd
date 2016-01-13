ActiveAdmin.register ContestPromocode do
  menu priority: 8

  controller do
    def scoped_collection
      super.joins(:contest).where("'contest_promocodes.contest.id' IS NOT NULL").
          joins(:promocode).where("'contest_promocodes.promocode.id' IS NOT NULL")
    end
  end

  index do
    selectable_column
    id_column
    column 'Client Name' do |code|
      code.contest.client.name
    end
    column 'Contest Name' do |code|
      code.contest.project_name
    end
    column 'Date Applied', :created_at
    column 'Promocode Name' do |code|
      code.promocode.promocode
    end
    column 'Message Displayed' do |code|
      code.promocode.display_message
    end
    column 'Discount Cents' do |code|
      code.promocode.discount_cents
    end
    actions
  end

  show do
    attributes_table do
      row 'Client Name' do |code|
        code.contest.client.name
      end
      row 'Contest Name' do |code|
        code.contest.project_name
      end
      row 'Date Applied', :created_at
      row 'Promocode Name' do |code|
        code.promocode.promocode
      end
      row 'Message Displayed' do |code|
        code.promocode.display_message
      end
      row 'Discount Cents' do |code|
        code.promocode.discount_cents
      end
    end
  end

end
