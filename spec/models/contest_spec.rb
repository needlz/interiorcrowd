require "rails_helper"

RSpec.describe Contest do
  let(:client) { Fabricate(:client) }
  let(:contest) do
    Fabricate(:contest,
              client: client,
              liked_examples: Fabricate.times(2, :example_image),
              space_images: Fabricate.times(2, :space_image)
    )
  end

  describe 'images association' do
    it 'updates liked examples' do
      old_examples = contest.liked_examples
      new_examples_ids = [old_examples[0].id, Fabricate(:image).id]
      expect(old_examples.count).to eq 2
      params = { design_style: { document_id: new_examples_ids.join(',') } }
      options = ContestOptions.new(params)
      contest.update_from_options(options)
      expect(contest.reload.liked_examples.pluck(:id)).to eq new_examples_ids
    end
  end
end