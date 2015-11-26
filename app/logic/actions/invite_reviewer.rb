class InviteReviewer

  attr_reader :invitation, :signed_url

  def initialize(options)
    @contest = options[:contest]
    @client = contest.client
    @invitation_attributes = options[:invitation_attributes]
    @view_context = options[:view_context]
  end

  def perform
    ActiveRecord::Base.transaction do
      @invitation = contest.reviewer_invitations.create!(invitation_attributes)
      @signed_url = view_context.show_reviewer_feedbacks_url(id: contest.id, token: invitation.url)
      Jobs::Mailer.schedule(:invitation_to_leave_a_feedback,
                            [invitation_attributes,
                             signed_url,
                             client.name,
                             Settings.app_url])
    end
  end

  private

  attr_reader :contest, :invitation_attributes, :view_context, :client

end
