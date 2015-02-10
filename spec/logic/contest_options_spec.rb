require "rails_helper"

RSpec.describe ContestOptions do

  def test_options(options, source)
    expect(options.contest).to eq({
                                        design_category_id: source[:design_brief][:design_category].to_i,
                                        design_space_id: source[:design_brief][:design_area].to_i,
                                        space_length: ContestOptions.calculate_inches(source[:design_space], :length),
                                        space_width: ContestOptions.calculate_inches(source[:design_space], :width),
                                        space_height: ContestOptions.calculate_inches(source[:design_space], :height),
                                        space_budget: source[:design_space][:f_budget],
                                        feedback: source[:design_space][:feedback],
                                        budget_plan: source[:preview][:b_plan],
                                        project_name: source[:preview][:contest_name],
                                        desirable_colors: source[:design_style][:desirable_colors],
                                        undesirable_colors: source[:design_style][:undesirable_colors],
                                        elements_to_avoid: source[:contest][:elements_to_avoid],
                                        entertaining: source[:contest][:entertaining],
                                        durability: source[:contest][:durability]
                                   })
    expect(options.appeals).to eq(source[:design_style][:appeals].deep_symbolize_keys)
    expect(options.space_image_ids).to eq(source[:design_space][:document_id].split(',').map(&:strip).map(&:to_i))
    expect(options.liked_example_ids).to eq(source[:design_style][:document_id].split(',').map(&:strip).map(&:to_i))
    expect(options.example_links).to eq(source[:design_style][:ex_links].map(&:strip))
    expect(options.preferred_retailers).to eq(source[:contest][:preferred_retailers])
  end

  it 'gets options from hash with symbol keys' do
    options = ContestOptions.new(contest_options_source)
    test_options(options, contest_options_source)
  end

  it 'gets options from hash with string keys' do
    options = ContestOptions.new(contest_options_source.stringify_keys)
    test_options(options, contest_options_source)
  end

  it 'removes blank example links' do
    params = contest_options_source.deep_dup
    params[:design_style][:ex_links] = params[:design_style][:ex_links] + ['', nil]
    options = ContestOptions.new(params)
    test_options(options, contest_options_source)
  end

end
