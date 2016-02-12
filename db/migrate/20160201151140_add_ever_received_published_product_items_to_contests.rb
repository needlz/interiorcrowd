class AddEverReceivedPublishedProductItemsToContests < ActiveRecord::Migration
  def change
    add_column :contests, :ever_received_published_product_items, :boolean

    Contest.all.each do |contest|
      ever_received_published_product_items = contest.response_winner && contest.response_winner.product_items.published.present?
      contest.update_column(:ever_received_published_product_items, ever_received_published_product_items)
    end
  end
end
