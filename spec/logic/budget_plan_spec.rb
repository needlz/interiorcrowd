require "rails_helper"

RSpec.describe BudgetPlan do

  describe '#find' do
    it 'raises error if unknown plan id passed' do
      expect { BudgetPlan.find(0) }.to raise_error(ArgumentError)
    end

    it 'returns plan by id' do
      expect(BudgetPlan.find(1)).to be_present
    end
  end

end