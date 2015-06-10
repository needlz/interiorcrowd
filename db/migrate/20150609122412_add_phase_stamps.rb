class AddPhaseStamps < ActiveRecord::Migration
  def change
    add_column :lookbook_details, :phase, :string
    ContestRequest.all.each do |r|
      last_phase_index = ContestPhases.status_to_index(r.status)
      next unless r.lookbook
      r.lookbook.lookbook_details.update_all("phase = '#{ ContestPhases.index_to_phase(last_phase_index) }'")
      lookbook_item = r.lookbook.lookbook_details.last
      0.upto(last_phase_index - 1).each do |phase_index|
        phase = ContestPhases.index_to_phase(phase_index)
        create_phase_stamp(phase.to_s, lookbook_item)
      end
    end
  end

  def create_phase_stamp(phase, lookbook_item)
    LookbookDetail.create!({lookbook_id: lookbook_item.lookbook_id,
                           image_id: lookbook_item.image_id,
                           doc_type: lookbook_item.doc_type,
                           description: lookbook_item.description,
                           phase: phase})
  end

end
