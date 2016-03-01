require "rails_helper"

RSpec.describe ContestRequestEditing do

  let(:request) { Fabricate(:contest_request,
                            designer: Fabricate(:designer),
                            contest: Fabricate(:contest_in_submission,
                                               client: Fabricate(:client)
                                              )
                            )
  }
  let(:params) do
    {
      product_items: {
        ids: [nil, nil],
        image_ids: [Fabricate(:image).id, Fabricate(:image).id],
        names: ['name 1', 'name 2'],
        brands: ['brand 1', 'brand 2'],
        prices: ['price 1', 'price 2'],
        links: ['link 1', 'link 2'],
        texts: ['text 1', 'text 2'],
        dimensions: ['dimension 1', 'dimension 2']
      }
    }
  end

  it 'new items have kind set to "product_items"' do
    expect(request.image_items).to be_empty
    editing = ContestRequestEditing.new(
      request: request,
      contest_request_options: params,
      contest_request_attributes: {}
    )
    editing.perform
    expect(request.image_items.pluck(:kind)).to eq ['product_items', 'product_items']
  end

end
