require 'rails_helper'

RSpec.describe ContestValidation::Submission do
  let(:requirements) do
    {
      design_brief: [:design_category_id, :design_space_ids],
      design_style: [:designer_level_id, :appeals, :desirable_colors],
      design_space: [:space_budget, :space_image_ids],
      preview: [:budget_plan, :project_name]
    }
  end
  let(:validation_class) { ContestValidation::Submission }

  it 'validates presence of required attributes' do
    expect(validation_class.required_options_by_step).to eq requirements
  end

end
