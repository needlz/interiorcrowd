class ContestView

  attr_reader :dimensions, :appeal_scales, :category, :design_area, :desirable_colors, :undesirable_colors, :examples,
              :links, :space_pictures, :budget, :feedback, :budget_plan, :name, :designer_level
  
  def initialize(options)
    if options.kind_of?(Hash)
      initialize_from_options(options)
    else
      initialize_from_contest(options)
    end
  end

  private

  def initialize_from_options(options)
    @category = DesignCategory.find_by_id(options['design_brief'].try(:[], :design_category))
    @design_area = DesignSpace.find_by_id(options['design_brief'].try(:[], :design_area))
    @designer_level = DesignerLevel.find_by_id(options['design_style'].try(:[], :designer_level))
    @appeal_scales = AppealScale.from(options['design_style'])
    @desirable_colors = options['design_style'].try(:[], 'desirable_colors')
    @undesirable_colors = options['design_style'].try(:[], 'undesirable_colors')
    @examples = options['design_style'].try(:[], 'document').try(:split, ',')
    @links = options['design_style'].try(:[], 'ex_links').try(:split, ',')
    @dimensions = SpaceDimension.from(options['design_space'])
    @space_pictures = options['design_space'].try(:[], 'document').try(:split, ',')
    @budget = Contest::CONTEST_DESIGN_BUDGETS[options['design_space'].try(:[], 'f_budget').to_i]
    @feedback = options['design_space'].try(:[], 'feedback')
    @budget_plan = options['preview'].try(:[], 'b_plan')
    @name = options['preview'].try(:[], 'contest_name')
  end

  def initialize_from_contest(contest)
    @category = contest.design_category
    @design_area = contest.design_space
    @designer_level = contest.client.designer_level
    @appeal_scales = AppealScale.from(contest.contests_appeals.includes(:appeal))
    @desirable_colors = contest.desirable_colors
    @undesirable_colors = contest.undesirable_colors
    @examples = contest.cd_style_ex_images.try(:split, ',') || []
    @links = contest.liked_external_examples.pluck(:url)
    @dimensions = SpaceDimension.from(contest)
    @space_pictures = contest.cd_space_images.try(:split, ',').try(:map) { |image_id| Image.find(image_id).image.url(:medium) }
    @budget = Contest::CONTEST_DESIGN_BUDGETS[contest.space_budget.to_i]
    @feedback = contest.feedback
    @budget_plan = contest.budget_plan
    @name = contest.project_name
  end

end