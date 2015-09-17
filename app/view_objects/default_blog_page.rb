class DefaultBlogPage

  def self.render(rendering_params, view_context)
    view_context.render 'shared/_blog_page', locals: rendering_params, layout: 'application'
  end

end
