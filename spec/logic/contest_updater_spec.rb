require 'rails_helper'

RSpec.describe ContestUpdater do

  let(:client) { Fabricate(:client, primary_card: Fabricate(:credit_card)) }
  let(:contest_with_space_images) do
    Fabricate(:contest,
              client: client,
              liked_examples: Fabricate.times(2, :example_image),
              space_images: Fabricate.times(2, :space_image),
              status: 'brief_pending'
    )
  end
  let(:contest_without_space_images) { Fabricate(:contest, client: client, status: 'brief_pending') }

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
    context 'when contest is payed' do
      before do
        pay_contest(contest_without_space_images)
      end

      it 'changes status to "submission"' do
        params = { design_space: { document_id: [Fabricate(:image).id].join(',') } }
        options = ContestOptions.new(params)
        updater = ContestUpdater.new(contest_without_space_images, options)
        updater.update_options
        expect(contest_without_space_images.status).to eq 'submission'
      end
    end
  end

end
