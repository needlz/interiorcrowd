class AddPaidForConceptBoardsToDesigners < ActiveRecord::Migration
  def change
    add_column :designers, :paid_for_concept_boards, :boolean, default: false
  end
end
