require 'rails_helper'

RSpec.describe ConceptBoardCommentUpdate do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, status: 'submitted') }
  let(:original_images) { Fabricate.times(2, :image) }
  let(:comment) do
    comment = Fabricate(:concept_board_client_comment, user_id: client.id, contest_request: contest_request)
    comment.attachments << original_images
    comment.save!
    comment
  end
  let(:updater) { ConceptBoardCommentUpdate.new(comment, comment_options) }

  context 'when new image ids added' do
    let(:new_image_id) { Fabricate(:image).id }
    let(:comment_options) { { attachment_ids: comment.attachment_ids + [new_image_id] } }

    it 'adds one new attachments' do
      expect(comment.reload.attachments.ids).to match_array original_images.map(&:id)
      updater.perform
      expect(comment.reload.attachments.ids).to match_array original_images.map(&:id) + [new_image_id]
    end
  end

  context 'when one image added and one removed' do
    let(:new_image_id) { Fabricate(:image).id }
    let(:comment_options) { { attachment_ids: [new_image_id, original_images[1].id] } }

    it 'adds one and removes one attachment' do
      expect(comment.reload.attachments.ids).to match_array original_images.map(&:id)
      updater.perform
      expect(comment.reload.attachments.ids).to match_array [new_image_id, original_images[1].id]
    end
  end

  context 'when all original images removed and one added' do
    let(:new_image_id) { Fabricate(:image).id }
    let(:comment_options) { { attachment_ids: [new_image_id] } }

    it 'removes original attachments and adds new attachment' do
      expect(comment.reload.attachments.ids).to match_array original_images.map(&:id)
      updater.perform
      expect(comment.reload.attachments.ids).to match_array [new_image_id]
    end
  end

end
