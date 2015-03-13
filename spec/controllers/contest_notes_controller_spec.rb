require 'rails_helper'

RSpec.describe ContestNotesController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client) }

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
          expect { post :create, contest_note: { contest_id: contest.id } }.to raise_error
          expect(contest.notes.count).to eq 0
        end

        it 'doesn\'t create an invitation if text is empty' do
          expect { post :create, contest_note: { contest_id: contest.id, text: '  ' } }.to raise_error
        end
      end

      context 'unexisting contest id' do
        it 'doesn\'t create an invitation' do
          expect { post :create, contest_note: { contest_id: 0, text: 'text' } }.to raise_error
        end
      end

      context 'correct contest id and text' do
        it 'creates an invitation' do
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
