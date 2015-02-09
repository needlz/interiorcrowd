class UpdateDesignerLevelTexts < ActiveRecord::Migration
  def change
    execute('UPDATE designer_levels SET name=\'novice\' WHERE id=1')
    execute('UPDATE designer_levels SET name=\'enthusiast\' WHERE id=2')
    execute('UPDATE designer_levels SET name=\'savvy\' WHERE id=3')
  end
end
