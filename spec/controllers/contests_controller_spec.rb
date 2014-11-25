require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestsController do
  let(:client) { Client.create!(email: 'client@example.com', first_name: 'First', last_name: 'Last', password: '123456') }
  let(:contest) { Contest.create!(client: client) }
  let(:appeals) { (0..2).map { |index| Appeal.create!(first_name: "first_name#{ index }", second_name: "second_name#{ index }") } }


  before do
    session[:client_id] = client.id
  end

  describe 'GET option' do
    render_views

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
    it 'updates appeals of contest' do
      appeal_values = Hash[appeals.map{ |appeal| [appeal.identifier, { value: Random.rand(0..100).to_s, reason: random_string }] }] #TODO
      patch :update, option: 'appeals', id: contest.id, design_style: { appeals: appeal_values }
      expect(contest.reload.contests_appeals.count).to eq 3
      contest.contests_appeals.includes(:appeal).each do |contest_appeal|
        expect(contest_appeal.value).to eq appeal_values[contest_appeal.appeal.identifier][:value].to_i
        expect(contest_appeal.reason).to eq appeal_values[contest_appeal.appeal.identifier][:reason]
      end
    end
  end
end
