require 'rails_helper'

RSpec.describe ContestNotesController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }

  describe 'POST create' do
    context 'not logged in' do
      it 'redirects to login page' do
        post :create, contest_note: { contest_id: contest.id, text: 'text' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'not creator of a contest' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'doesn\'t create an invitation' do
        post :create, contest_note: { contest_id: contest.id, text: 'text' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'logged in' do
      before do
        sign_in(client)
      end

      context 'without text' do
        it 'doesn\'t create an invitation if text is not passed' do
          expect { post :create, contest_note: { contest_id: contest.id } }.to raise_error(ActiveRecord::RecordInvalid)
          expect(contest.notes.count).to eq 0
        end

        it 'doesn\'t create an invitation if text is empty' do
          expect { post :create, contest_note: { contest_id: contest.id, text: '  ' } }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'unexisting contest id' do
        it 'doesn\'t create an invitation' do
          expect { post :create, contest_note: { contest_id: 0, text: 'text' } }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'correct contest id and text' do
        it 'creates an comment' do
          post :create, contest_note: { contest_id: contest.id, text: 'text' }
          note = contest.notes[0]
          expect(note.text).to eq 'text'
        end

        it 'saves client id' do
          note_text = 'text'
          post :create, contest_note: { contest_id: contest.id, text: note_text }
          expect(contest.notes[0].client).to eq client
          expect(contest.notes[0].designer).to be_nil
        end

        it 'renders notes list' do
          post :create, contest_note: { contest_id: contest.id, text: 'text' }
          expect(response).to render_template(partial: '_notes_list')
        end

        context 'contest has subscribed designers' do
          let(:not_participating_designer) { Fabricate(:designer) }
          let(:designer_with_request) { Fabricate(:designer) }
          let(:request) { Fabricate(:contest_request, designer: designer_with_request, contest: contest) }

          before do
            contest.notes.create!(designer: designer, text: 'comment')
            Fabricate(:contest_request,
                      designer: designer_with_request,
                      contest: Fabricate(:contest, status: 'submission'))
          end

          it 'notifies subscribed designers' do
            comment_text = 'text'
            request
            post :create, contest_note: { contest_id: contest.id, text: comment_text }
            expect(designer.reload.user_notifications.reload.count).to eq 1
            expect(designer_with_request.reload.user_notifications.reload.count).to eq 1
            notification = designer.user_notifications.find_by_type('ContestCommentDesignerNotification')
            notification2 = designer_with_request.user_notifications.find_by_type('ContestCommentDesignerNotification')
            expect(not_participating_designer.user_notifications).to be_empty
            expect(notification2.contest_comment.text).to eq comment_text
            expect(notification.contest_comment.text).to eq comment_text
          end
        end
      end
    end

    context 'logged in as designer' do
      before do
        sign_in(designer)
      end

      it 'saves designer id' do
        note_text = 'text'
        post :create, contest_note: { contest_id: contest.id, text: note_text }
        expect(contest.notes[0].designer).to eq designer
        expect(contest.notes[0].client).to be_nil
      end
    end
  end

end
