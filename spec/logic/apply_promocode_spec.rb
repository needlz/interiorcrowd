require 'rails_helper'

RSpec.describe ApplyPromocode do

  let(:client){ Fabricate(:client) }
  let(:contest){ Fabricate(:contest_in_submission, client: client) }
  let(:apply) { ApplyPromocode.new(contest, promocode.promocode) }

  context 'when promocode is one-time' do
    let(:promocode) { Fabricate(:promocode, one_time: true) }

    it 'deactivates promocode' do
      apply.perform
      expect(promocode.reload).to_not be_active
    end
  end

  context 'when promocode is not one-time' do
    let(:promocode) { Fabricate(:promocode, one_time: false) }

    it 'does not deactivate promocode' do
      apply.perform
      expect(promocode.reload).to be_active
    end
  end

end
