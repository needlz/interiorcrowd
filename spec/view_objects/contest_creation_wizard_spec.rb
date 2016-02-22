require 'rails_helper'

RSpec.describe ContestCreationWizard do
  let(:room) { DesignSpace.create }
  let(:completion_procedures) do
    { 0 => {
      semicomplete: ->(contest){ contest.update_attributes!(design_category_id: 1) },
      complete: ->(contest) do
        contest.update_attributes!(design_category_id: 1)
        contest.design_spaces << room
      end
    },
      1 => {
        semicomplete: ->(contest) do
          Fabricate.times(2, :appeal)
          contest.update_attributes!(desirable_colors: '#000000')
          contest.appeals << Appeal.last
        end,
        complete: ->(contest) do
          Fabricate.times(2, :appeal).each { |style| contest.appeals << style }
          contest.update_attributes!(desirable_colors: '#000000', designer_level_id: 1)
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
    Fabricate(:contest)
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
        expect(ContestCreationWizard.finished_step?(contest.reload, step_index)).to be_truthy
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
