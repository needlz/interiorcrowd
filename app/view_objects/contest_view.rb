class ContestView

  attr_reader :dimensions, :appeal_scales, :category, :design_area, :desirable_colors, :undesirable_colors, :examples,
              :links, :space_pictures, :budget, :feedback, :budget_plan, :name, :designer_level, :example_ids, :space_pictures_ids

  EDITABLE_ATTRIBUTES = [:category, :area, :appeals, :desirable_colors, :undesirable_colors,
        :example_pictures, :example_links, :space_pictures, :space_dimensions, :budget, :feedback]

  def initialize(options)
    if options.kind_of?(Hash)
      initialize_from_options(HashWithIndifferentAccess.new(options))
    else
      initialize_from_contest(options)
    end
  end

  private

  def initialize_from_options(options)
    contest_options = ContestOptions.new(options)
    contest_params = contest_options.contest
    @category = DesignCategory.find_by_id(contest_params[:design_category_id])
    @design_area = DesignSpace.find_by_id(contest_params[:design_space_id])
    @designer_level = DesignerLevel.find_by_id(contest_options.designer_level)
    @appeal_scales = AppealScale.from(contest_options.appeals)
    @desirable_colors = contest_params[:desirable_colors]
    @undesirable_colors = contest_params[:undesirable_colors]
    @examples = contest_options.liked_example_ids.try(:map) { |example_id| Image.find(example_id).image.url(:medium) }
    @example_ids = contest_options.liked_example_ids
    @links = contest_options.example_links
    @dimensions = SpaceDimension.from(contest_params)
    @space_pictures = contest_options.space_image_ids.try(:map) { |example_id| Image.find(example_id).image.url(:medium) }
    @space_pictures_ids = contest_options.space_image_ids
    @budget = Contest::CONTEST_DESIGN_BUDGETS[contest_params[:space_budget].to_i]
    @feedback = contest_params[:feedback]
    @budget_plan = contest_params[:budget_plan]
    @name = contest_params[:project_name]
  end

  def initialize_from_contest(contest)
    @category = contest.design_category
    @design_area = contest.design_space
    @designer_level = contest.client.designer_level
    @appeal_scales = AppealScale.from(contest.contests_appeals.includes(:appeal))
    @desirable_colors = contest.desirable_colors
    @undesirable_colors = contest.undesirable_colors
    @examples = contest.liked_examples.map { |example| example.image.url(:medium) }
    @example_ids = contest.liked_examples.pluck(:id)
    @links = contest.liked_external_examples.pluck(:url)
    @dimensions = SpaceDimension.from(contest)
    @space_pictures = contest.space_images.map { |space_image| space_image.image.url(:medium) }
    @space_pictures_ids = contest.space_images.pluck(:id)
    @budget = Contest::CONTEST_DESIGN_BUDGETS[contest.space_budget.to_i]
    @feedback = contest.feedback
    @budget_plan = contest.budget_plan
    @name = contest.project_name
  end
end