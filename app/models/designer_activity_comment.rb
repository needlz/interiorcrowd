class DesignerActivityComment < ActiveRecord::Base

  belongs_to :designer_activity
  belongs_to :author, polymorphic: true

  def global_author
    self.author.to_global_id if self.author.present?
  end

  def global_author=(author)
    self.author = GlobalID::Locator.locate author
  end

end
