class RemoveContestCdStyleLinks < ActiveRecord::Migration
  def change
    Contest.all.each do |contest|
      next unless contest.cd_style_links
      contest.cd_style_links.split(',').map(&:strip).each do |url|
        contest.liked_external_examples << ImageLink.new(url: url)
      end
    end

    remove_column :contests, :cd_style_links
  end
end
