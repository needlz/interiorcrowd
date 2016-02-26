class AddLookbookItems < Action

  def initialize(contest_request, items_attributes, phase)
    @contest_request = contest_request
    @lookbook = contest_request.lookbook
    @items_attributes = items_attributes
    @phase = phase
  end

  def perform
    ActiveRecord::Base.transaction do
      @lookbook ||= Lookbook.create!
      contest_request.update_attributes(lookbook_id: lookbook.id)
      p items_attributes
      if items_attributes.try(:[], :picture).try(:[], :ids).present?
        images_ids = items_attributes[:picture][:ids].split(',')
        p images_ids
        images_ids.each do |image_id|
          LookbookDetail.create!(lookbook_id: lookbook.id,
                                 image_id: image_id,
                                 phase: phase)
        end
      end
    end
  end

  private

  attr_reader :lookbook, :items_attributes, :phase, :contest_request

end
