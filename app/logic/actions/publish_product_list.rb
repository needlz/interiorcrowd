class PublishProductList

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    ActiveRecord::Base.transaction do
      remove_previous_published_items
      create_published_copy_of_temporary_items
    end
  end

  private

  attr_reader :contest_request

  def remove_previous_published_items
    contest_request.image_items.published.destroy_all
  end

  def create_published_copy_of_temporary_items
    contest_request.image_items.temporary.publish
  end

end
