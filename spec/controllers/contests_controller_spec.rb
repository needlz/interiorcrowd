require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestsController do
  render_views

  let(:client) { Fabricate(:client) }
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
      expect(response).to redirect_to(entries_client_center_index_path)
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
        prepare_params
      end

      it 'creates contest' do
        post :save_preview, contest_options_source
        expect(client.contests.count).to eq 2
        expect(response).to redirect_to(entries_client_center_index_path)
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
end
