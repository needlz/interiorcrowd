class PublishProductList

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    ActiveRecord::Base.transaction do
      rewrite_published_copy_of_temporary_items
    end
  end

  private

  attr_reader :contest_request

  def rewrite_published_copy_of_temporary_items
    copyist = ActiveRecordStampCreator.new(
        records: contest_request.image_items.temporary,
        new_attributes: { status: 'published' }
    )
    new_items = []

    copyist.perform do |new_item, item|
      new_item.temporary_version = item
      new_item.mark = item.published_version.try(:mark)
      new_items << new_item
    end

    contest_request.image_items.published.destroy_all

    new_items.each { |item| item.save! }
  end

end
