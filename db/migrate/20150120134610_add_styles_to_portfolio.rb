class AddStylesToPortfolio < ActiveRecord::Migration
  STYLES = %w(modern vintage traditional contemporary coastal global
                eclectic hollywood_glam midcentury_modern transitional rustic_elegance color_pop)

  def up
    change_table(:portfolios) do |t|
      STYLES.each do |style|
        t.boolean "#{style}_style", default: false
      end
    end
  end

  def down
    STYLES.each do |style|
      remove_column :portfolios, "#{style}_style"
    end
  end
end
