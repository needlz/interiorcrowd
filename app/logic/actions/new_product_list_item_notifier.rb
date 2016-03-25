class NewProductListItemNotifier
  def initialize(request)
    @request = request
    @client = request.contest.client
  end

  def perform
    send_email
  end

  private

  attr_reader :request, :client

  def send_email
    Jobs::Mailer.schedule(:new_product_list_item,
                          [client.id],
                          { contest_request_id: request.id })
  end

end