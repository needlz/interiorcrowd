require 'rails_helper'

RSpec.describe ContestUpdater do

  let(:client) { Fabricate(:client) }
  let(:contest_with_space_images) do
    Fabricate(:contest,
              client: client,
              liked_examples: Fabricate.times(2, :example_image),
              space_images: Fabricate.times(2, :space_image)
    )
  end
  let(:contest_without_space_images) { Fabricate(:contest, client: client) }

  it 'updates liked examples' do
    old_examples = contest_with_space_images.liked_examples
    new_examples_ids = [old_examples[0].id, Fabricate(:image).id]
    params = { design_style: { document_id: new_examples_ids.join(',') } }
    options = ContestOptions.new(params)
    updater = ContestUpdater.new(contest_with_space_images, options)
    updater.update_options
    expect(contest_with_space_images.reload.liked_examples.pluck(:id)).to match_array new_examples_ids
  end

  describe 'upload space images' do
    it 'changes status to "submission"' do
      params = { design_space: { document_id: [Fabricate(:image).id].join(',') } }
      options = ContestOptions.new(params)
      updater = ContestUpdater.new(contest_without_space_images, options)
      updater.update_options
      expect(contest_without_space_images.status).to eq 'submission'
    end
  end

end