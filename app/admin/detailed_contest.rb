ActiveAdmin.register Contest, as: "Detailed Contest" do
  actions :all, :except => [:new, :destroy, :edit, :show]

  index do
    selectable_column
    column 'Contest id' do |contest|
      link_to contest.id, admin_contest_path(contest)
    end
    column 'Contest' do |contest|
      client = contest.client
      full_contest_name = link_to(client.first_name.to_s + ' ' + client.last_name.to_s.possessive,
                                  admin_client_path(client)) + ' ' + contest.project_name + " (##{contest.id})"
      full_contest_name.html_safe
    end
    column 'Start Date' do |contest|
      contest.submission_started_at
    end
    column 'Designers' do |contest|
      contest.requests.ever_published.map do |request|
        designer = request.designer
        statement = link_to(designer.first_name.to_s + ' ' + designer.last_name.to_s, admin_designer_path(designer))
        statement = statement + ', submitted at ' + request.submitted_at.to_s if request.submitted_at
        statement
      end.join('<br />').html_safe
    end
    column 'Winner' do |contest|
      if contest.response_winner
        designer = contest.response_winner.designer
        statement = link_to(designer.first_name.to_s + ' ' + designer.last_name.to_s, admin_designer_path(designer))
        statement = statement + ', won at ' + contest.response_winner.won_at.to_s if contest.response_winner.won_at
        statement.html_safe
      end
    end
    column 'End Date' do |contest|
      if %w[finished closed].include? contest.status
        contest.status.to_s.capitalize + ' at ' + contest.finished_at.to_s if contest.finished_at
      end
    end
  end

  filter :id, label: 'Contest ID'
  filter :client
  filter :project_name
  filter :submission_started_at, label: 'Start Date'
  filter :finished_at, label: 'End Date'
end
