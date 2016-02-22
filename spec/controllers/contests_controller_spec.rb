require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestsController do
  render_views

  let(:client) { Fabricate(:client, primary_card: Fabricate(:credit_card)) }
  let(:designer) { Fabricate(:designer_with_portfolio) }
  let(:contest) { Fabricate(:completed_contest, client: client, status: 'brief_pending') }
  let(:appeals) { (0..2).map { |index| Appeal.create!(name: "name#{ index }") } }

  def prepare_contest_data
    session.merge!(contest_options_source)
  end

  def set_primary_card(client)
    client.update_attributes!(primary_card_id: Fabricate(:credit_card, client: client).id)
  end

  describe 'GET option' do
    before do
      sign_in(client)
    end

    it 'returns html of options' do
      allow_any_instance_of(DesignCategory).to receive(:name).and_return('quick_fix')
      ContestView::EDITABLE_ATTRIBUTES.each do |option|
        get :option, id: contest.id, option: option
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(partial: "contests/options/_#{ option }_options")
      end
    end

    it 'throws exception if unknown option was passed' do
      expect { get :option, id: contest.id, option: '' }.to raise_error(ActionView::MissingTemplate)
    end
  end

  describe 'PATCH update' do
    before do
      sign_in(client)
    end

    let(:appeal_values){ Hash[appeals.map{ |appeal| [appeal.identifier, { value: Random.rand(0..100).to_s, reason: random_string }] }] }

    it 'updates appeals of contest' do
      dont_raise_i18n_exceptions do
        allow_any_instance_of(AppealScale).to receive(:name) { |key| 'string' }
        patch :update, option: 'design_profile', id: contest.id, design_style: { appeals: appeal_values }
        appeal_values.each do |identifier, value|
          appeal = Appeal.all.detect { |appeal| appeal.identifier == identifier }
          contest_appeal = contest.contests_appeals.where(appeal_id: appeal.id).first
          expect(contest_appeal.value).to eq value[:value].to_i
          expect(contest_appeal.reason).to eq value[:reason]
        end
      end
    end

    it 'redirects to Entries page after pictures dimension edited' do
      patch :update, option: 'space_dimensions', id: contest.id, pictures_dimension: true
      expect(response).to redirect_to(client_center_entry_path(id: contest.id))
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

    context 'user is logged in' do
      before do
        sign_in(client)
        contest
      end

      context 'when contest not payed' do
        context 'when valid id passed' do
          let(:id) { contest.id }

          it 'renders page' do
            get :payment_details, id: id
            expect(response).to render_template(:payment_details)
          end
        end

        context 'invalid id passed' do
          it 'returns 404' do
            get :payment_details, id: 0
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'when contest payed' do
        before do
          Fabricate(:client_payment, contest: contest)
        end

        it 'redirects to payment summary' do
          get :payment_details, id: contest.id
          expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
        end
      end
    end

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
          before do
            contest.status = 'finished'
            contest.save!
          end

          it 'creates contest' do
            post :save_preview, contest_options_source
            expect(client.contests.count).to eq 2
          end

          it 'redirect to credit cards page' do
            post :save_preview, contest_options_source
            expect(response).to redirect_to(payment_details_contests_path(id: client.contests.last.id))
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
        expect(response.body).to eq ''
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
    context 'when logged in as contest owner' do
      before do
        sign_in(client)
        Fabricate(:portfolio)
        mock_file_download_url
      end

      let(:contest) { Fabricate(:contest_in_submission, client: client) }
      let(:submitted_request) { Fabricate(:contest_request,
                                          designer: designers[0],
                                          contest: contest,
                                          status: 'submitted',
                                          lookbook: Fabricate(:lookbook)) }
      let(:draft_request) { Fabricate(:contest_request,
                              designer: designers[1],
                              contest: contest,
                              status: 'draft',
                              lookbook: Fabricate(:lookbook)) }
      let(:fulfillment_request) { Fabricate(:contest_request,
                                    designer: designers[2],
                                    contest: contest,
                                    status: 'fulfillment_ready',
                                    lookbook: Fabricate(:lookbook)) }

      context 'designers present' do
        let!(:designers) { Fabricate.times(4, :portfolio).map(&:designer) }

        context 'when no contest requests submitted' do
          it 'shows designers invitation page' do
            contest = Fabricate(:completed_contest, client: client)
            pay_contest(contest)
            get :show, id: contest.id
            expect(response).to render_template(:entries_invitations)
          end

          it 'does not track visit time' do
            get :show, id: contest.id
            expect(submitted_request.reload.last_visit_by_client_at).to be_nil
          end
        end

        it 'returns page' do
          Fabricate(:contest_in_submission, client: client)
          contest = Fabricate(:completed_contest, client: client)
          pay_contest(contest)
          get :show, id: contest.id
          expect(response).to render_template(:entries_invitations)
        end

        context 'when contest request id passed instead' do
          let(:id) { submitted_request.id }

          it 'returns page' do
            pay_contest(contest)
            get :show, id: id
            expect(response).to redirect_to(client_center_entry_path(contest.id))
          end
        end

        context 'responses present' do
          def create_contest_request(cont)
            Fabricate(:contest_request,
                      designer: designers[3],
                      contest: cont,
                      status: 'submitted',
                      answer: 'winner',
                      lookbook: Fabricate(:lookbook))
          end

          def create_contest
            Fabricate(:contest_in_submission, client: client)
          end

          before do
            pay_contest(contest)
            draft_request
            submitted_request
            fulfillment_request
          end

          it 'views only submitted and fulfillment requests' do
            get :show, id: contest.id
            expect(assigns(:entries_page).contest_requests).to match_array([submitted_request, fulfillment_request])
          end

          it 'filters responses by answer' do
            contest.start_winner_selection!
            draft_request.update_attributes!(answer: 'no')
            fulfillment_request.update_attributes!(answer: 'favorite')
            submitted_request.update_attributes!(answer: 'winner')
            get :show, answer: 'winner', id: contest.id
            expect(assigns(:entries_page).contest_requests).to match_array([submitted_request])
          end

          it 'returns winner contest request' do
            contest.start_winner_selection!
            submitted_request.update_attributes!(answer: 'winner')
            get :show, answer: 'winner', id: contest.id
            expect(assigns(:entries_page).won_contest_request).to eq(submitted_request)
          end

          context 'contest in fulfillment state' do
            before do
              fulfillment_request.update_attributes!(answer: 'winner')
              contest.update_attributes!(status: 'fulfillment')
            end

            it 'returns page' do
              ContestRequest::FULFILLMENT_STATUSES.each do |status|
                cont = create_contest
                pay_contest(cont)
                contest_request = create_contest_request(cont)
                contest_request.update_attributes!(status: status)
                cont.update_attributes!(status: 'fulfillment')
                PhasesStripe::PHASES.each_index do |index|
                  get :show, view: index, id: cont.id
                  if index == ContestPhases.phase_to_index(:initial)
                    expect(response).to render_template(partial: 'clients/client_center/entries/_entries')
                  else
                    expect(response).to render_template(partial: 'clients/client_center/entries/_entry')
                  end
                end
                contest_request.destroy
              end
            end

            it 'tracks visit time' do
              get :show, id: contest.id
              expect(fulfillment_request.reload.last_visit_by_client_at).to be_within(5.second).of(Time.current)
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

      context 'when real payments disabled' do
        context 'when contest payed' do
          it 'returns entries page' do
            pay_contest(contest)
            get :show, id: contest.id
            expect(response).to render_template(:entries_invitations)
          end
        end

        context 'when contest not payed' do
          context 'when credit cards saved' do
            before do
              set_primary_card(client)
            end

            it 'returns entries page' do
              pay_contest(contest)
              get :show, id: contest.id
              expect(response).to render_template(:entries_invitations)
            end
          end

          context 'when credit cards not saved' do
            it 'redirects to payment details page' do
              get :show, id: contest.id
              expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
            end
          end
        end
      end

      context 'when real payments enabled' do
        context 'when contest payed' do
          it 'returns entries page' do
            pay_contest(contest)
            get :show, id: contest.id
            expect(response).to render_template(:entries_invitations)
          end
        end

        context 'when contest not payed' do
          context 'when credit cards saved' do
            before do
              set_primary_card(client)
            end

            it 'redirects to payment details page' do
              get :show, id: contest.id
              expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
            end
          end

          context 'when credit cards not saved' do
            it 'redirects to payment details page' do
              get :show, id: contest.id
              expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
            end
          end
        end
      end

      def create_request(options)
        contest_options = { client: client, status: 'submission' }
        contest_options.merge!(options[:contest].try(:except, :status)) if options[:contest]
        @contest = Fabricate(:completed_contest, contest_options)
        pay_contest(@contest)
        @contest_request = Fabricate(:contest_request,
                                     { designer: Fabricate(:designer_with_portfolio),
                                       contest: @contest,
                                       lookbook: Fabricate(:lookbook)
                                     }.merge(options[:contest_request])
        )
        @contest.update_attributes!(status: options[:contest][:status]) if options[:contest].try(:[], :status)
      end

      context 'when contest in "submission" state' do
        it 'returns page' do
          create_request(contest_request: { status: 'finished',
                                            answer: 'winner' })
          client.update_attributes!(status: 'finished')
          @contest_request.image_items.create!(kind: 'product_items', phase: 'collaboration', status: 'temporary')
          @contest_request.image_items.create!(kind: 'product_items', phase: 'final_design', status: 'published')
          get :show, id: @contest.id
          expect(response).to render_template('clients/client_center/entries')
          ContestPhases::INDICES_TO_PHASES.keys.each do |phase_index|
            get :show, view: phase_index, id: @contest.id
            expect(response).to render_template('clients/client_center/entries')
          end
        end
      end

      context 'when contest in "winner_selection" state' do
        it 'returns page' do
          create_request(contest: { status: 'winner_selection' }, contest_request: { status: 'submitted' })
          get :show, id: @contest.id
          expect(response).to render_template('clients/client_center/entries')
        end
      end

      context 'when contest in "fulfillment" state' do
        it 'returns page' do
          create_request(contest: { status: 'fulfillment' },
                         contest_request: { status: 'fulfillment_ready', answer: 'winner' })
          get :show, id: @contest.id
          expect(response).to render_template('clients/client_center/entries')
        end
      end

      context 'when contest in "final_fulfillment" state' do
        it 'returns page' do
          create_request(contest: { status: 'final_fulfillment' },
                         contest_request: { status: 'fulfillment_ready', answer: 'winner' })
          get :show, id: @contest.id
          expect(response).to render_template('clients/client_center/entries')
        end
      end

      context 'when contest in "finished" state' do
        before do
          create_request(contest: { status: 'finished' },
                         contest_request: { status: 'finished', answer: 'winner' })
          Fabricate(:product_item, contest_request: @contest_request, phase: 'collaboration')
        end

        it 'returns page' do
          get :show, id: @contest.id
          expect(response).to render_template('clients/client_center/entries')
        end

        it 'renders view of collaboration phase' do
          get :show, id: @contest.id, view: ContestPhases.phase_to_index(:collaboration)
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

    context 'when logged in as another client' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'does not find resource' do
        get :show, id: contest.id
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged in' do
      before do
        pay_contest(contest)
      end

      context 'when not invited to review' do
        it 'redirect to client login page' do
          get :show, id: contest.id
          expect(response).to redirect_to(client_login_sessions_path)
        end
      end

      context 'when invited to review' do
        before do
          invite = InviteReviewer.new(contest: contest,
                                      view_context: RenderingHelper.new,
                                      invitation_attributes: { username: 'username', email: 'email@example.com' })
          invite.perform
          cookies[:reviewer_token] = invite.invitation.url
        end

        it 'returns page' do
          get :show, id: contest.id
          expect(response).to render_template('clients/client_center/entries')
        end
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

  describe 'GET payment_summary' do
    context 'when the contest is payed' do
      before do
        Fabricate(:client_payment,
                  contest: contest,
                  client: client,
                  amount_cents: 30000,
                  promotion_cents: 0,
                  credit_card: Fabricate(:credit_card))
      end

      context 'when signed in as client' do
        before do
          sign_in(client)
        end

        it 'returns page' do
          get :payment_summary, id: contest.id
          expect(response).to render_template(:payment_summary)
        end
      end
    end
  end

  describe 'GET intake form steps for a new contest' do
    context 'when logged as client' do
      before do
        sign_in(client)
      end

      context 'when there is an incomplete contest' do
        let!(:incomplete_contest) { Fabricate(:contest, client: client) }

        it 'redirects to contest editing' do
          get :design_brief
          expect(response).to redirect_to design_brief_contest_path(id: incomplete_contest.id )
        end
      end

      context 'when there is no incomplete contest' do
        it 'returns page' do
          dont_raise_i18n_exceptions do
            get :design_brief
            expect(response).to be_ok
          end
        end
      end
    end

    context 'when not logged as client' do
      it 'returns page' do
        dont_raise_i18n_exceptions do
          get :design_brief
          expect(response).to be_ok
        end
      end
    end
  end

  describe 'GET intake form steps for incomplete contest' do
    let(:submitted_contest) { Fabricate(:contest_in_submission) }

    context 'when logged as client' do
      before do
        sign_in(client)
      end

      context 'when an incomplete contest exists' do
        let!(:incomplete_contest) { Fabricate(:contest, client: client) }

        before do
          Fabricate(:contest, client: client)
        end

        it 'renders page' do
          dont_raise_i18n_exceptions do
            get :design_brief, id: incomplete_contest.id
            expect(response).to be_ok
          end
        end
      end

      context 'when a contest is completed' do
        let!(:completed_contest) { Fabricate(:completed_contest, client: client, status: 'brief_pending') }

        it 'redirects to contest brief page' do
          get :design_brief, id: submitted_contest.id
          expect(response).to redirect_to brief_contest_path(id: submitted_contest.id)
        end
      end

      context 'when there is no incomplete contest' do
        it 'returns 404' do
          get :design_brief, id: 0
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when not logged as client' do
      it 'returns 404' do
        get :design_brief, id: submitted_contest.id
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST intake form step for a new contest' do
    context 'when logged as client' do
      before do
        sign_in(client)
      end

      context 'when there is an incomplete contest' do
        let!(:incomplete_contest) { Fabricate(:contest, client: client) }

        it 'reloads page in context of the incomplete contest' do
          post :save_design_brief
          expect(response).to redirect_to design_brief_contest_path(id: incomplete_contest.id)
        end
      end

      context 'when there is no incomplete contest' do

        it 'redirects to next step in context of the incomplete contest' do
          post :save_design_brief
          new_contest = client.contests.first
          expect(response).to redirect_to design_style_contest_path(id: new_contest.id)
        end

        it 'creates incomplete contest' do
          expect { post :save_design_brief }.to change{ client.reload.contests.count }.from(0).to(1)
        end
      end
    end

    context 'when not logged as client' do
      it 'returns next step' do
        post :save_design_brief
        expect(response).to redirect_to design_style_contests_path
      end
    end
  end

  describe 'POST intake form step for incomplete contest' do
    before do
      sign_in(client)
    end

    context 'when there is an incomplete contest' do
      let!(:incomplete_contest) { Fabricate(:contest, client: client) }

      it 'saves changes' do
        post :save_design_brief, contest_options_source.merge(id: incomplete_contest.id)
        expect(response).to redirect_to design_style_contest_path(id: incomplete_contest.id)
        expect(incomplete_contest.reload.design_space_ids).to eq contest_options_source[:design_brief][:design_area]
      end
    end

    context 'when a wrong contest id specified' do
      it 'returns 404' do
        post :save_design_brief, id: 0
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when specified contest is completed' do
      let(:completed_contest) { Fabricate(:completed_contest, client: client, status: 'brief_pending') }

      it 'returns 404' do
        post :save_design_brief, contest_options_source.merge(id: completed_contest.id)
        expect(response).to have_http_status(:not_found)
      end
    end

  end

  describe 'GET invite_designers' do
    before do
      sign_in(client)
    end

    context 'when contest is in "Submission" Phase' do
      let(:contest) { Fabricate(:contest_in_submission, client: client) }

      it 'renders page' do
        get :invite_designers, id: contest.id
        expect(response).to render_template(:invite_designers)
      end
    end

    context 'when contest is not in "Submission" Phase' do
      let(:contest) { Fabricate(:completed_contest, client: client) }

      it 'returns 404' do
        expect(contest.status).not_to eq('submission')
        get :invite_designers, id: contest.id
        expect(response).to have_http_status(:not_found)
      end
    end

  end

end
