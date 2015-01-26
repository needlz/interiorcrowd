require 'rails_helper'

RSpec.describe ContestNotesController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

  describe 'POST create' do
    context 'not logged in' do
      it 'redirects to login page' do
        post :create, contest_id: contest.id, text: 'text'
        expect(response).to redirect_to client_login_sessions_path
      end
    end

    context 'not creator of a contest' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'doesn\'t create an invitation' do
        post :create, contest_id: contest.id, text: 'text'
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end

    context 'logged in' do
      before do
        sign_in(client)
      end

      context 'without text' do
        it 'doesn\'t create an invitation if text is not passed' do
          expect { post :create, contest_id: contest.id }.to raise_error
          expect(contest.notes.count).to eq 0
        end

        it 'doesn\'t create an invitation if text is empty' do
          expect { post :create, contest_id: contest.id, text: '  ' }.to raise_error
        end
      end

      context 'unexisting contest id' do
        it 'doesn\'t create an invitation' do
          expect { post :create, contest_id: 0, text: 'text' }.to raise_error
        end
      end

      context 'correct contest id and text' do
        it 'creates an invitation' do
          post :create, contest_id: contest.id, text: 'text'
          note = contest.notes[0]
          expect(note.text).to eq 'text'
        end

        it 'notifies about success' do
          post :create, contest_id: contest.id, text: 'text'
          expect(response).to be_ok
        end
      end
    end
  end

end
