class ImageItemsController < ApplicationController
  before_filter :set_designer, only: [:create, :update, :default]
  before_filter :set_client, only: [:mark]
  before_filter :set_contest_request, only: [:create]
  before_filter :set_item, only: [:update, :mark, :edit, :destroy]

  def create
    product_item = ImageItem.create!(product_item_params)
    render json: product_item.to_json
  end

  def update
    return raise_404 unless @item.contest_request.designer == @designer
    @item.update_attributes!(product_item_params)
    render partial: 'designer_center_requests/edit/image_content',
           locals: { item: ImageItemView.new(@item), editable: true, mode: :view }
  end

  def mark
    return raise_404 unless @item.contest_request.contest.client == @client
    ImageItemUpdater.new(@item, params[:image_item]).perform
    render json: { updated: @item }
  end

  def new
    render partial: 'designer_center_requests/edit/image_item',
           locals: { image_item: ImageItemView.new(ImageItem.new(kind: 'product_items')) }
  end

  def edit
    render partial: 'designer_center_requests/edit/edit_image_item',
           locals: { item: ImageItemView.new(@item) }
  end

  def destroy
    @item = @item.destroy
    render json: { destroyed: @item.destroyed? }
  end

  def default
    contest_request = @designer.contest_requests.find(params[:contest_request_id])
    item_view = ImageItemView.new(ImageItem.create!(kind: params[:kind],
                                                    contest_request_id: contest_request.id,
                                                    image_id: params[:image_id] ))
    render partial: 'designer_center_requests/edit/image_content', locals: { item: item_view, editable: true, mode: :edit }
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

  def set_item
    @item = ImageItem.find(params[:id])
  end
end
