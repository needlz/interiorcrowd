class CreateFinalNote

  attr_reader :final_note

  def initialize(options)
    @contest_request = options[:contest_request]
    @author = options[:author]
    @custom_final_note_attributes = options[:final_note_attributes]
    raise ArgumentError.new('user is not allowed to leave a final note') unless user_allowed?
  end

  def perform
    ActiveRecord::Base.transaction do
      create_final_note
      create_designer_notification if author.client?
    end
  end

  private

  attr_reader :contest_request, :custom_final_note_attributes, :author

  def create_final_note
    final_note_attributes = custom_final_note_attributes.merge(author_id: author.id,
                                                               author_role: author.role,
                                                               contest_request_id: contest_request.id)
    @final_note = FinalNote.new(final_note_attributes)
    @final_note.save!
  end

  def create_designer_notification
    FinalNoteDesignerNotification.create!(user_id: contest_request.designer_id,
                                          contest_request_id: contest_request.id,
                                          final_note_id: final_note.id)
  end

  def user_allowed?
    contest_request.contest_owner?(author) || contest_request.designer == author
  end

end
