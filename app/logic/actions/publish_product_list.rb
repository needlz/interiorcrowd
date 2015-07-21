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
    new_items = []
    contest_request.image_items.temporary.each do |item|
      new_item = item.dup
      new_item.status = 'published'
      new_item.temporary_version = item
      new_item.mark = item.published_version.try(:mark)
      new_items << new_item
    end
    contest_request.image_items.published.destroy_all
    new_items.each { |item| item.save! }
  end

end
