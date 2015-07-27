class AddPhaseToImageItems < ActiveRecord::Migration
  def change
    add_column :image_items, :phase, :string, default: :collaboration

    final_items = ImageItem.joins(:contest_request).where(contest_requests: { status: 'finished' }).where('final = ? OR mark = ? OR mark IS NULL', true, ImageItem::MARKS[:LIKE])
    final_items.update_all('phase = \'final_design\'')
  end
end
