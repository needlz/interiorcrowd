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

  describe 'GET option' do
    it 'returns html of options' do
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
      patch :update, option: 'appeals', id: contest.id, design_style: { appeals: appeal_values }
      appeal_values.each do |identifier, value|
        appeal = Appeal.all.detect { |appeal| appeal.identifier == identifier }
        contest_appeal = contest.contests_appeals.where(appeal_id: appeal.id).first
        expect(contest_appeal.value).to eq value[:value].to_i
        expect(contest_appeal.reason).to eq value[:reason]
      end
    end
  end
end
