require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestsController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:appeals) { (0..2).map { |index| Appeal.create!(name: "name#{ index }") } }

  def prepare_contest_data
    session.merge!(contest_options_source)
  end

  describe 'GET option' do
    before do
      sign_in(client)
    end

    it 'returns html of options' do
      allow_any_instance_of(DesignCategory).to receive(:name).and_return('quick_fix')
      ContestView::EDITABLE_ATTRIBUTES.each do |option|
        get :option, id: contest.id, option: option
        expect(response).to be_ok
        expect(response).to render_template(partial: "contests/options/_#{ option }_options")
      end
    end

    it 'throws exception if unknown option was passed' do
      expect { get :option, id: contest.id, option: '' }.to raise_error
    end
  end

  describe 'PATCH update' do
    before do
      sign_in(client)
    end

    let(:appeal_values){ Hash[appeals.map{ |appeal| [appeal.identifier, { value: Random.rand(0..100).to_s, reason: random_string }] }] }

    it 'updates appeals of contest' do
      allow_any_instance_of(AppealScale).to receive(:name) { |key| 'string' }
      patch :update, option: 'design_profile', id: contest.id, design_style: { appeals: appeal_values }
      appeal_values.each do |identifier, value|
        appeal = Appeal.all.detect { |appeal| appeal.identifier == identifier }
        contest_appeal = contest.contests_appeals.where(appeal_id: appeal.id).first
        expect(contest_appeal.value).to eq value[:value].to_i
        expect(contest_appeal.reason).to eq value[:reason]
      end
    end

    it 'redirects to Entries page after pictures dimension edited' do
      patch :update, option: 'space_dimensions', id: contest.id, pictures_dimension: true
      expect(response).to redirect_to(client_center_entries_path)
    end
  end

  describe 'GET preview' do
    before do
      sign_in(client)
    end

    context 'previous steps completed' do
      before do
        prepare_contest_data
      end

      it 'renders page' do
        get :preview
        expect(response).to be_ok
        expect(response).to render_template(:preview)
      end
    end

    context 'previous steps uncompleted' do
      it 'redirects to uncompleted page' do
        get :preview
        expect(response).to redirect_to ContestCreationWizard.creation_steps_paths.values[0]
      end
    end
  end

  describe 'GET account_creation' do
    context 'previous steps completed' do
      before do
        prepare_contest_data
      end

      it 'renders page' do
        get :account_creation
        expect(response).to be_ok
        expect(response).to render_template(:account_creation)
      end
    end

    context 'previous steps uncompleted' do
      it 'redirects to uncompleted page' do
        get :account_creation
        expect(response).to redirect_to ContestCreationWizard.creation_steps_paths.values[0]
      end
    end

    context 'some data of preview step not passed' do
      before do
        prepare_contest_data
        session[:preview][:b_plan] = nil
      end

      it 'redirects to preview page' do
        get :account_creation
        expect(response).to redirect_to ContestCreationWizard.creation_steps_paths[:preview]
      end
    end
  end

  describe 'GET payment_details' do

    context 'user is not logged in' do
      it 'redirects to client sign in page' do
        get :payment_details
        expect(response).to redirect_to client_login_sessions_path
      end
    end

    context 'user is not a client' do
      before do
        sign_in(designer)
      end

      it 'redirects to client sign in page' do
        get :payment_details
        expect(response).to redirect_to client_login_sessions_path
      end
    end

  end

  describe 'POST save_preview' do
    def prepare_params
      session.merge!(contest_options_source.except(:preview))
    end

    it 'reloads page if "preview" parameter was not passed' do
      prepare_params
      post :save_preview
      expect(response).to redirect_to(preview_contests_path)
    end

    it 'redirects to account creation page if user is not logged in as client' do
      prepare_params
      post :save_preview, contest_options_source
      expect(response).to redirect_to(account_creation_contests_path)
    end

    context 'logged in as client' do
      before do
        sign_in(client)
        contest
      end

      context 'with all steps completed' do
        before do
          prepare_params
        end

        context 'and active contest status' do
          it 'raises an exception' do
            expect do
              post :save_preview, contest_options_source
            end.to raise_error(ArgumentError)
            expect(client.contests.count).to eq 1
          end
        end

        context 'and inactive contest status' do
          it 'creates contest' do
            contest.status = 'finished'
            contest.save!
            post :save_preview, contest_options_source
            expect(client.contests.count).to eq 2
            expect(response).to redirect_to(client_center_entries_path)
          end
        end


      end

      context 'when required steps not stored in session' do
        it 'redirects to uncompleted step' do
          post :save_preview, preview: { contest_name: 'any name' }
          expect(response).to redirect_to(ContestCreationWizard.creation_steps_paths[:design_brief])
        end
      end
    end
  end

  describe 'GET download_all_images_url' do
    before do
      Fabricate(:space_image, contest: contest)
      allow_any_instance_of(ImagesArchiveGeneration).to receive(:completed?) { false }
      allow_any_instance_of(ImagesArchiveGeneration).to receive(:download_url) { 'url' }
      allow_any_instance_of(ImagesArchiveGeneration).to receive(:send_to_s3) do
        allow_any_instance_of(ImagesArchiveGeneration).to receive(:completed?) { true }
      end
    end

    context 'if no valid image type passed' do
      let(:params) { { id: contest.id } }

      it 'returns 404' do
        get :download_all_images_url, params
        expect(response).to have_http_status(:not_found)
      end

      it 'does not schedule job' do
        !jobs_with_handler_like(Jobs::GeneratePhotosArchive.name).exists?
      end
    end

    context 'if wrong image type passed' do
      let(:params) { { id: contest.id, type: 'what?' } }

      it 'raises error if wrong image type passed' do
        expect{ get :download_all_images_url, params }.to raise_error(ArgumentError)
      end

      it 'does not schedule job' do
        !jobs_with_handler_like(Jobs::GeneratePhotosArchive.name).exists?
      end
    end

    context 'if valid image type passed' do
      let(:params) { { id: contest.id, type: 'space_images' } }

      it 'returns nothing if archivation not yet performed' do
        get :download_all_images_url, params
        expect(response.body).to eq ' '
      end

      it 'schedules job' do
        get :download_all_images_url, params
        expect(jobs_with_handler_like(Jobs::GeneratePhotosArchive.name).count).to eq 1
      end

      it 'returns archive path if archivation performed' do
        allow_any_instance_of(Image).to receive(:image_file_name) { "#{ Random.rand }.file" }
        allow_any_instance_of(Image).to receive(:image) do
          o = Object.new
          def o.copy_to_local_file(style, path)
            File.open path, "w" do |file|
              file.write('text')
            end
          end
          o
        end
        get :download_all_images_url, params
        job = jobs_with_handler_like(Jobs::GeneratePhotosArchive.name).first
        job.invoke_job
        job.destroy
        get :download_all_images_url, params
        expect(response.body).to be_present
        FileUtils.rm_rf(Dir["#{ Rails.root }/tmp/image_archives/*"])
      end
    end
  end

  describe 'GET design_style' do
    it 'renders page' do
      get :design_style
      expect(response).to render_template(:design_style)
    end
  end

  describe 'GET design_space' do
    it 'renders page' do
      get :design_space
      expect(response).to render_template(:design_space)
    end
  end

  describe 'GET design_brief' do
    it 'renders page' do
      get :design_brief
      expect(response).to render_template(:design_brief)
    end
  end

  describe 'GET show' do
    before do
      sign_in(client)
      Fabricate(:portfolio)
      allow_any_instance_of(Image).to receive(:url_for_downloading) { '' }
    end

    context 'designers present' do
      let!(:designers) { Fabricate.times(4, :portfolio).map(&:designer) }

      it 'returns page' do
        Fabricate(:contest, client: client, status: 'submission')
        get :show, id: Fabricate(:contest, client: client).id
        expect(response).to render_template(:entries_invitations)
      end

      context 'responses present' do
        let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
        let!(:submitted) { Fabricate(:contest_request,
                                     designer: designers[0],
                                     contest: contest,
                                     status: 'submitted',
                                     lookbook: Fabricate(:lookbook)) }
        let!(:draft) { Fabricate(:contest_request,
                                 designer: designers[1],
                                 contest: contest,
                                 status: 'draft',
                                 lookbook: Fabricate(:lookbook)) }
        let!(:fulfillment) { Fabricate(:contest_request,
                                       designer: designers[2],
                                       contest: contest,
                                       status: 'fulfillment_ready',
                                       lookbook: Fabricate(:lookbook)) }

        def create_contest_request(cont)
          Fabricate(:contest_request,
                    designer: designers[3],
                    contest: cont,
                    status: 'submitted',
                    answer: 'winner',
                    lookbook: Fabricate(:lookbook))
        end

        def create_contest
          Fabricate(:contest, client: client, status: 'submission')
        end

        it 'views only submitted and fulfillment requests' do
          get :show, id: contest.id
          expect(assigns(:entries_page).contest_requests).to match_array([submitted, fulfillment])
        end

        it 'filters responses by answer' do
          contest.start_winner_selection!
          draft.update_attributes!(answer: 'no')
          fulfillment.update_attributes!(answer: 'favorite')
          submitted.update_attributes!(answer: 'winner')
          get :show, answer: 'winner', id: contest.id
          expect(assigns(:entries_page).contest_requests).to match_array([submitted])
        end

        it 'returns winner contest request' do
          contest.start_winner_selection!
          submitted.update_attributes!(answer: 'winner')
          get :show, answer: 'winner', id: contest.id
          expect(assigns(:entries_page).won_contest_request).to eq(submitted)
        end

        context 'contest in fulfillment state' do
          before do
            contest.update_attributes!(status: 'fulfillment')
          end

          it 'returns page' do
            ContestRequest::FULFILLMENT_STATUSES.each do |status|
              cont = create_contest
              contest_request = create_contest_request(cont)
              contest_request.update_attributes!(status: status)
              cont.update_attributes!(status: 'fulfillment')
              PhasesStripe::PHASES.each_index do |index|
                get :show, view: index, id: cont.id
                expect(response).to render_template('clients/client_center/entries')
              end
              contest_request.destroy
            end
          end
        end

        context 'contest finished' do
          it 'returns page' do
            contest_request = Fabricate(:contest_request,
                                        designer: designers[3],
                                        contest: contest,
                                        status: 'finished',
                                        answer: 'winner',
                                        lookbook: Fabricate(:lookbook))
            contest.update_attributes!(status: 'finished')
            PhasesStripe::PHASES.each_index do |index|
              get :show, view: index, id: contest.id
              expect(response).to render_template('clients/client_center/entries')
            end
          end
        end
      end
    end

    it 'returns page' do
      Fabricate(:contest, client: client, status: 'submission')
      contest = client.last_contest
      client.update_attributes!(status: 'finished')
      fulfillment = Fabricate(:contest_request,
                              designer: Fabricate(:designer),
                              contest: contest,
                              status: 'finished',
                              answer: 'winner',
                              lookbook: Fabricate(:lookbook))
      fulfillment.image_items.create!(kind: 'product_items', phase: 'collaboration', status: 'temporary')
      fulfillment.image_items.create!(kind: 'product_items', phase: 'final_design', status: 'published')
      fulfillment.image_items.create!(kind: 'product_items', phase: 'collaboration', status: 'temporary')
      fulfillment.image_items.create!(kind: 'product_items', phase: 'final_design', status: 'published')
      get :show, id: contest.id
      expect(response).to render_template('clients/client_center/entries')
      ContestPhases::INDICES_TO_PHASES.keys.each do |phase_index|
        get :show, view: phase_index, id: contest.id
        expect(response).to render_template('clients/client_center/entries')
      end
    end

    context 'client has no contest' do
      before do
        client.contests.destroy_all
      end

      it 'redirects to contest creation' do
        get :show, id: 0
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET index' do
    before do
      sign_in(client)
    end

    it 'returns page' do
      get :index
      expect(response).to render_template(:index)
    end
  end

end
