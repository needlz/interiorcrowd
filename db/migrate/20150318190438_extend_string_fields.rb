class ExtendStringFields < ActiveRecord::Migration
  def change
    columns = {
        clients: [:first_name, :last_name, :email, :name_on_card, :card_type, :address, :state, :card_number,
                  :city, :phone_number, :billing_address, :billing_state, :billing_city],
        contests: [:desirable_colors, :undesirable_colors, :project_name, :billing_city],
        design_categories: [:name],
        design_spaces: [:name],
        designer_levels: [:name],
        designers: [:first_name, :last_name, :email, :zip, :ex_links, :ex_document_ids,
                    :portfolio_path, :phone_number, :plain_password],
        example_links: [:url],
        image_links: [:url],
        lookbook_details: [:url],
        portfolios: [:school_name, :degree, :path],
        reviewer_invitations: [:username, :email, :url]
    }
    columns.each do |table, columns|
      columns.each do |column|
        change_column(table, column, :text) if column_exists?(table, column)
      end
    end
  end
end
