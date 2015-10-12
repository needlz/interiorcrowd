ActiveAdmin.register Contest, as: "Detailed Contest" do
  actions :all, :except => [:new, :destroy, :edit]

  index do
    selectable_column
    id_column
    column 'Contest' do |contest|
      client = contest.client
      full_contest_name = link_to(client.first_name.to_s + ' ' + client.last_name.to_s.possessive,
                                  admin_client_path(client)) + ' ' + contest.project_name
      full_contest_name.html_safe
    end
    column 'Date' do |contest|
      contest.client_payment.created_at if contest.client_payment
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
      contest.finished_at
    end
    actions
  end
end
