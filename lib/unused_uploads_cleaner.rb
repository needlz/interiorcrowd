class UnusedUploadsCleaner

  def self.perform
    p Rails.env
    used_ids = (ConceptBoardCommentAttachment.all.pluck(:attachment_id) +
        Image.where('(contest_id IS NOT NULL) OR (portfolio_id IS NOT NULL)').pluck(:id) +
        Portfolio.all.pluck(:background_id) +
        ImageItem.all.pluck(:image_id) +
        LookbookDetail.all.pluck(:image_id)).uniq
    p "used: #{ used_ids.length } files"
    unused_images = Image.where.not(id: used_ids)
    p "to remove: #{ unused_images.count } files"
    unused_images.each do |image|
      image.destroy
    end
  end

end
