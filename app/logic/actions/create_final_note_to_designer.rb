class CreateFinalNoteToDesigner

  def initialize(options)
    @contest_request = options[:contest_request]
    @client = options[:client]
    @final_note_attributes = options[:final_note_attributes]
  end

  def perform
    ActiveRecord::Base.transaction do
      notification = FinalNoteDesignerNotification.create!(user_id: contest_request.designer_id,
                                            contest_request_id: contest_request.id)
      final_note = new_final_note
      final_note.designer_notification_id = notification.id
      final_note.save!
    end
  end

  private

  attr_reader :contest_request, :final_note_attributes, :client

  def new_final_note
    FinalNoteToDesigner.new(final_note_attributes)
  end

end
