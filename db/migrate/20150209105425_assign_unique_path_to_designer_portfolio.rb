class AssignUniquePathToDesignerPortfolio < ActiveRecord::Migration
  Designer.all.each do |designer|
    Portfolio.create(designer_id: designer.id) unless designer.portfolio
    Portfolio.reset_column_information
    Designer.reset_column_information
    designer.portfolio.assign_unique_path if designer.portfolio
  end
end

