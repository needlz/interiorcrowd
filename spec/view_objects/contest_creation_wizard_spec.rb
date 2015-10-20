require 'rails_helper'

RSpec.describe ContestCreationWizard do

  let(:completion_procedures) do
    { 0 => {
      semicomplete: ->(contest){ contest.update_attributes!(design_category_id: 1) },
      complete: ->(contest){ contest.update_attributes!(design_category_id: 1, design_space_id: 1) }
    },
      1 => {
        semicomplete: ->(contest) do
          Fabricate.times(2, :appeal)
          contest.update_attributes!(desirable_colors: '#000000')
          contest.appeals << Appeal.first
        end,
        complete: ->(contest) do
          Fabricate.times(2, :appeal)
          contest.update_attributes!(desirable_colors: '#000000')
          Appeal.all.each { |style| contest.appeals << style }
        end
      },
      2 => {
        semicomplete: ->(contest){ },
        complete: ->(contest) { contest.update_attributes!(space_budget: '$100') }
      },
      3 => {
        semicomplete: ->(contest){ contest.update_attributes!(project_name: 'Test project') },
        complete: ->(contest) { contest.update_attributes!(project_name: 'Test project', budget_plan: 1) }
      }
    }
  end

  let(:contest) do
    Fabricate(:contest,
              project_name: nil,
              design_category: nil,
              design_space: nil,
              budget_plan: nil)
  end

  describe '#finished_step?' do
    it 'returns false for empty and semi-complete steps' do
      (0..(ContestCreationWizard.steps_count - 1)).each do |step_index|
        expect(ContestCreationWizard.finished_step?(contest, step_index)).to be_falsey

        completion_procedures[step_index][:semicomplete].call(contest)
        expect(ContestCreationWizard.finished_step?(contest, step_index)).to be_falsey
      end
    end

    it 'returns true for complete steps' do
      (0..(ContestCreationWizard.steps_count - 1)).each do |step_index|
        completion_procedures[step_index][:complete].call(contest)
        expect(ContestCreationWizard.finished_step?(contest, step_index)).to be_truthy
      end
    end

  end

  describe '#unfinished_step' do
    it 'returns first uncomplete step' do
      completion_procedures[0][:complete].call(contest)
      completion_procedures[1][:complete].call(contest)
      expect(ContestCreationWizard.unfinished_step(contest)).to eq 2
    end

  end

end