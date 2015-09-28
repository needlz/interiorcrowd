class ImageItemsController < ApplicationController
  before_filter :set_designer, only: [:create, :update, :default]
  before_filter :set_client, only: [:mark]
  before_filter :set_contest_request, only: [:create]
  before_filter :set_item, only: [:update, :mark, :edit, :destroy]

  def create
    contest_request = @designer.contest_requests.find(product_item_params[:contest_request_id])
    phase = ContestPhases.status_to_phase(contest_request.status)
    product_item = contest_request.image_items.of_phase(phase).create!(product_item_params)
    render json: product_item.to_json
  end

  def update
    return raise_404 unless @item.contest_request.designer == @designer
    ImageItemUpdater.new(@item, product_item_params, current_user).perform
    render partial: 'designer_center_requests/edit/image_content',
           locals: { item: ImageItemView.new(@item) }
  end

  def mark
    return raise_404 unless @item.contest_request.contest.client == @client
    ImageItemUpdater.new(@item, params[:image_item], current_user).perform
    render json: { updated: @item }
  end

  def new
    new_item = ImageItem.new(kind: 'product_items', phase: 'final_design')
    render partial: 'designer_center_requests/edit/image_item',
           locals: { image_item: ImageItemView.new(new_item) }
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
    phase = ContestPhases.status_to_phase(contest_request.status)
    new_image_item = contest_request.image_items.of_phase(phase).create!(kind: params[:kind],
                                                                         image_id: params[:image_id])
    render partial: 'designer_center_requests/edit/image_content', locals: { item: ImageItemView.new(new_image_item) }
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

  def set_item
    @item = ImageItem.find(params[:id])
  end
end
