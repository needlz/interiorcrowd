require 'rails_helper'

RSpec.describe ContestUpdater do

  let(:client) { Fabricate(:client, primary_card: Fabricate(:credit_card)) }
  let(:contest_with_space_images) do
    Fabricate(:completed_contest,
              client: client,
              liked_examples: Fabricate.times(2, :example_image),
              space_images: Fabricate.times(2, :space_image),
              status: 'brief_pending'
    )
  end
  let(:contest_without_space_images) { Fabricate(:completed_contest,
                                                 client: client,
                                                 status: 'brief_pending',
                                                 was_in_brief_pending_state: true) }

  describe 'upload space images' do
    context 'when contest is charged' do
      before do
        pay_contest(contest_without_space_images)
      end

      context 'when contest was initially with completed brief' do
        it 'updates liked examples' do
          old_examples = contest_with_space_images.liked_examples
          new_examples_ids = [old_examples[0].id, Fabricate(:image).id]
          params = { design_style: { document_id: new_examples_ids.join(',') } }
          options = ContestOptions.new(params)
          updater = ContestUpdater.new(contest_with_space_images, options)
          updater.update_options
          expect(contest_with_space_images.reload.liked_examples.pluck(:id)).to match_array new_examples_ids
        end

        it 'does not notify owner about a contest went live' do
          params = { design_space: { document_id: [Fabricate(:image).id].join(',') } }
          options = ContestOptions.new(params)
          updater = ContestUpdater.new(contest_with_space_images, options)
          updater.update_options

          SubmitContest.new(contest_with_space_images).try_perform
          expect(jobs_with_handler_like('new_project_to_hello').count).to eq 0
        end
      end

      context 'when contest was initially with incomplete brief' do
        it 'changes status to "submission"' do
          params = { design_space: { document_id: [Fabricate(:image).id].join(',') } }
          options = ContestOptions.new(params)
          updater = ContestUpdater.new(contest_without_space_images, options)
          updater.update_options
          expect(contest_without_space_images.status).to eq 'submission'
        end

        it 'notifies owner about a contest went live' do
          params = { design_space: { document_id: [Fabricate(:image).id].join(',') } }
          options = ContestOptions.new(params)
          updater = ContestUpdater.new(contest_without_space_images, options)
          updater.update_options

          SubmitContest.new(contest_without_space_images).try_perform
          expect(jobs_with_handler_like('new_project_to_hello').count).to eq 1
        end
      end
    end
  end

end
