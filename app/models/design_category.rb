class DesignCategory < ActiveRecord::Base
  
  ACTIVE_STATUS = 1

  has_many :contests

  scope :available, ->{ where(status: ACTIVE_STATUS).order(pos: :asc) }

  def localized_name
    I18n.t("contests.titles.brief.packages.#{ name }.name")
  end

end
