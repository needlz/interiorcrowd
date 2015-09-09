class AdminBlogPage

  def self.render(rendering_params, view_context)
    view_context.render text: '', locals: rendering_params, layout: 'admin_page'
  end

end
