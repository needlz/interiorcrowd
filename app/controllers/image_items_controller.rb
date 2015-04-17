class ImageItemsController < ApplicationController
  before_filter :set_designer, only: [:create, :update]
  before_filter :set_client, only: [:mark]
  before_filter :set_contest_request, only: [:create]

  def create
    product_item = ImageItem.create!(product_item_params)
    render json: product_item.to_json
  end

  def update
    product_item = ImageItem.find(params[:id])
    return raise_404 unless product_item.contest_request.designer == @designer
    product_item.update_attributes!(product_item_params)
    render nothing: true
  end

  def mark
    product_item = ImageItem.find(params[:id])
    return raise_404 unless product_item.contest_request.contest.client == @client
    ImageItemUpdater.new(product_item, params[:image_item]).perform
    render json: { updated: product_item }
  end

  def new
    render partial: 'designer_center_requests/edit/image_item', locals: { image_item: ImageItemView.new(ImageItem.new(kind: 'product_items')) }
  end

  private

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def product_item_params
    params.require(:image_item).permit(:image_id, :text, :name, :price, :brand, :link, :contest_request_id, :kind,
                                       :dimensions)
  end

  def set_contest_request
    @contest_request = @designer.contest_requests.find_by_id(product_item_params[:contest_request_id])
    raise_404 unless @contest_request
  end

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end

  def set_client
    @client = Client.find_by_id(check_client)
  end
end
