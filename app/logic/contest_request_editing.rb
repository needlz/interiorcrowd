class ContestRequestEditing

  def initialize(options)
    @request = options[:request]
    @contest_request = options[:contest_request]
  end

  def perform
    update_image
    update_text
    update_status
  end

  private

  def update_image
    if contest_request['image_id']
      lookbook_id = request.lookbook.id
      details = LookbookDetail.find_by_lookbook_id(lookbook_id)
      details.update(image_id: contest_request['image_id'])
    end
  end

  def update_text
    if contest_request['feedback']
      request.update(feedback: contest_request['feedback'])
    end
  end

  def update_status
    request.submit! if @contest_request[:status] == 'submitted'
  end

  attr_reader :request, :contest_request

end