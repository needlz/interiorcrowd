class LookbookDetailsController < ApplicationController
  include RequiresDesigner

  before_filter :set_designer
  before_filter :set_contest_request, only: [:create, :destroy]
  before_filter :set_lookbook_detail, only: [:destroy]

  def create
    item_creation = LookbookDetailCreation.new(@contest_request, lookbook_detail_params)
    item_creation.perform
    render partial: 'designer_center_requests/showcase',
           locals: { showcase: Showcase.new(items: @contest_request.current_lookbook_items,
                     editable: true) }
  end

  def destroy
    @lookbook_detail.destroy!
    render partial: 'designer_center_requests/showcase',
           locals: { showcase: Showcase.new(items: @contest_request.current_lookbook_items,
                     editable: true) }
  end

  def preview
    image_ids = params[:image_ids].split(',')
    images = Image.where(id: image_ids)
    render partial: 'designer_center_requests/showcase',
           locals: { showcase: Showcase.new(images: images,
                     editable: true) }
  end

  private

  def lookbook_detail_params
    params.require(:lookbook_detail).permit(:image_id)
  end

  def set_contest_request
    @contest_request = @designer.contest_requests.find(params[:designer_center_response_id])
  end

  def set_lookbook_detail
    @lookbook_detail = @contest_request.lookbook.lookbook_details.find(params[:id])
  end

end
