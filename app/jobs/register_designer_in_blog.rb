class RegisterDesignerInBlog < ActiveJob::Base
  queue_as Jobs::BLOG_QUEUE

  def perform(designer_id)
    designer = Designer.find(designer_id)
    Blog::UserRegistration.perform(designer)
  rescue StandardError => exception
    ErrorsLogger.log(exception, { designer_id: designer_id })
  end
end
