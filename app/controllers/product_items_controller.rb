class ProductItemsController < ApplicationController
  before_filter :set_designer
  before_filter :set_contest_request

  def create
    product_item = ProductItem.create!(product_item_params)
    render json: product_item.to_json
  end

  def update
    product_item = @contest_request.product_items.find(params[:id])
    product_item.update_attributes!(product_item_params)
    render nothing: true
  end

  private

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def product_item_params
    params.require(:product_item).permit(:image_id, :text, :name, :price, :brand, :link, :contest_request_id)
  end

  def set_contest_request
    @contest_request = @designer.contest_requests.find_by_id(product_item_params[:contest_request_id])
    raise_404 unless @contest_request
  end

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end

end
