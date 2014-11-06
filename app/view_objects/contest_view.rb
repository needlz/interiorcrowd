class ContestView

  attr_reader :dimensions, :appeal_scales, :categories, :design_areas, :favorited_colors, :avoided_colors, :examples,
              :links, :space_pictures, :budget, :feedback
  
  def initialize(options)
    if options.kind_of?(ActionDispatch::Request::Session)
      initialize_from_options(options)
    else
      initialize_from_contest(options)
    end
  end

  private

  def initialize_from_options(options)
    @categories = DesignCategory.where("id IN (?)", options[:design_categories].try(:[], :cat_id)).order(:pos)
    @design_areas = DesignSpace.where("id IN (?)", options[:space_areas]).order(:pos)
    @appeal_scales = AppealScale.from(options[:design_style])
    @favorited_colors = options[:design_style].try(:[], :fav_color)
    @avoided_colors = options[:design_style].try(:[], :refrain_color)
    @examples = options[:design_style].try(:[], :document).try(:split, ',')
    @links = options[:design_style].try(:[], :ex_links)
    @dimensions = SpaceDimension.from(options[:design_space])
    @space_pictures = options[:design_space].try(:[], :document).try(:split, ',')
    @budget = Contest::CONTEST_DESIGN_BUDGETS[options[:design_space].try(:[], :f_budget).to_i]
    @feedback = options[:design_space].try(:[], :feedback)
  end

  def initialize_from_contest(contest)
    @categories = DesignCategory.where("id IN (?)", contest.cd_cat.split(',')).order(:pos)
    @design_areas = DesignSpace.where("id IN (?)", contest.cd_space.split(',')).order(:pos)
    @appeal_scales = AppealScale.from(contest)
    @favorited_colors = contest.cd_fav_color
    @avoided_colors = contest.cd_refrain_color
    @examples = contest.cd_style_ex_images.split(',')
    @links = contest.cd_style_links
    @dimensions = SpaceDimension.from(contest)
    @space_pictures = contest.cd_space_images.split(',').map { |image_id| Image.find(image_id).image.url(:medium) }
    @budget = Contest::CONTEST_DESIGN_BUDGETS[contest.cd_space_budget.to_i]
    @feedback = contest.feedback
  end

end