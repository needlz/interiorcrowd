class ContestView

  attr_reader :dimensions, :appeal_scales, :category, :design_area, :desirable_colors, :undesirable_colors, :examples,
              :links, :space_pictures, :budget, :feedback, :budget_plan, :name, :designer_level

  OPTIONS_PARTIALS = [:category, :area, :appeals, :desirable_colors, :undesirable_colors,
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
    contest_attributes = Contest.options_from_hash(options)
    contest_params = contest_attributes[:contest]
    contest_associations = contest_attributes[:contest_associations]
    @category = DesignCategory.find_by_id(contest_params[:design_category_id])
    @design_area = DesignSpace.find_by_id(contest_params[:design_space_id])
    @designer_level = DesignerLevel.find_by_id(contest_params[:designer_level])
    @appeal_scales = AppealScale.from(contest_params)
    @desirable_colors = contest_params[:desirable_colors]
    @undesirable_colors = contest_params[:undesirable_colors]
    @examples = contest_associations[:liked_example_urls]
    @links = contest_associations[:example_links]
    @dimensions = SpaceDimension.from(contest_params)
    @space_pictures = contest_associations[:space_image_urls]
    @budget = Contest::CONTEST_DESIGN_BUDGETS[contest_params[:space_budget]]
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
    @links = contest.liked_external_examples.pluck(:url)
    @dimensions = SpaceDimension.from(contest)
    @space_pictures = contest.space_images.map { |space_image| space_image.image.url(:medium) }
    @budget = Contest::CONTEST_DESIGN_BUDGETS[contest.space_budget.to_i]
    @feedback = contest.feedback
    @budget_plan = contest.budget_plan
    @name = contest.project_name
  end
end