class DesignerInboxCommentsQuery

  def initialize(designer)
    @designer = designer
  end

  def all
    concept_board_comments + contest_comments
  end

  private

  attr_reader :designer

  def contest_comments
    notes = ContestNote.arel_table
    designer_notes = Arel::Table.new(:contest_notes, as: :designer_notes)
    designer_responses = Arel::Table.new(:contest_requests, as: :designer_request)
    contests = Contest.arel_table

    commented_contests = designer_notes.project(Arel.sql('id')).
      where(designer_notes[:designer_id].eq(designer.id).
      and(designer_notes[:contest_id].eq(notes[:contest_id])))

    participated_contests = designer_responses.project(Arel.sql('id')).
      where(designer_responses[:designer_id].eq(designer.id).
      and(designer_responses[:contest_id].eq(contests[:id])))

    ContestNote.joins(:contest).
      where(notes[:client_id].not_eq(nil)).
      where(commented_contests.exists.or(participated_contests.exists))
  end

  def concept_board_comments
    designer.comments.by_client.includes(contest_request: [:contest])
  end

end
