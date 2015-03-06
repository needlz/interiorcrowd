require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestsController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:appeals) { (0..2).map { |index| Appeal.create!(first_name: "first_name#{ index }", second_name: "second_name#{ index }") } }

  before do
    session[:client_id] = client.id
  end

  def prepare_contest_data
    session.merge!(contest_options_source)
  end

  describe 'GET option' do
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
    let(:appeal_values){ Hash[appeals.map{ |appeal| [appeal.identifier, { value: Random.rand(0..100).to_s, reason: random_string }] }] }

    it 'updates appeals of contest' do
      allow_any_instance_of(AppealScale).to receive(:name) { |key| key }
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
end
