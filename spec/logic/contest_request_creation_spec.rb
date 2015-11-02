require 'rails_helper'

RSpec.describe ContestRequestCreation do

  let(:designer){ Fabricate(:designer) }
  let(:contest){ Fabricate(:contest, status: 'submission') }
  let(:creation) do
    ContestRequestCreation.new(designer: designer,
                               contest: contest,
                               need_submit: false)
  end

  context 'on concurrent calls', concurrent: true do
    it 'creates one contest request' do
      expect do
        creation.concurrent_calls([:create_request], :perform) do |processes|
          processes[0].run_until(:create_request).wait
          processes[1].run_until(:create_request) && sleep(0.1)
          processes[0].finish.wait
          processes[1].finish.wait
        end
      end.to raise_error(Fork::UndumpableException, /ActiveRecord::RecordNotUnique/)
      expect(ContestRequest.count).to eq 1
    end
  end
end

