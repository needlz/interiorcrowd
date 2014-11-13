class RemoveContestImageFileds < ActiveRecord::Migration
  def change
    Contest.all.each do |contest|
      if contest.cd_space_images
        contest.add_images(contest.cd_space_images.split(',').map(&:strip).map(&:to_i), ContestsImage::SPACE)
      end
      if contest.cd_style_ex_images
        contest.add_images(contest.cd_style_ex_images.split(',').map(&:strip).map(&:to_i), ContestsImage::LIKED_EXAMPLE)
      end
    end

    remove_columns :contests, :cd_style_ex_images, :cd_space_images
  end
end
