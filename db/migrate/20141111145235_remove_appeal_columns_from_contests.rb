class RemoveAppealColumnsFromContests < ActiveRecord::Migration
  def change
    remove_columns :contests,
                   :feminine_appeal_scale,
                   :elegant_appeal_scale,
                   :traditional_appeal_scale,
                   :muted_appeal_scale,
                   :conservative_appeal_scale,
                   :timeless_appeal_scale,
                   :fancy_appeal_scale
  end
end
