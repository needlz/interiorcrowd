class TrackContestRequestVisit

  def self.perform(contest_request)
    contest_request.update_attributes!(last_visit_by_client_at: Time.current)
  end

end
