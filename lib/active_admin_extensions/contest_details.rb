module ActiveAdminExtensions

  module ContestDetails
    def end_date(contest)
      if %w[finished closed].include? contest.status
        formatted_date(contest.status.to_s.capitalize + ' at ', contest.finished_at)
      end
    end

    def contest_name(contest)
      client = contest.client
      full_contest_name = link_to(full_user_name(client).possessive, admin_client_path(client)) + append_project_name(contest)
      full_contest_name.html_safe
    end

    def full_user_name(user)
      return user.first_name.to_s unless user.last_name
      return user.last_name.to_s unless user.first_name
      user.first_name + ' ' + user.last_name
    end

    def append_project_name(contest)
      ' ' + contest.project_name.to_s + " (##{contest.id})"
    end

    def designers_list(contest)
      contest.requests.ever_published.map do |request|
        designer = request.designer
        statement = link_to(full_user_name(designer), admin_designer_path(designer))
        statement = statement + formatted_date(', submitted at ', request.submitted_at)
        statement
      end.join('<br />').html_safe
    end

    def formatted_date(status_prefix, date)
      status_prefix + date.to_s if date
    end

    def winner_info(contest)
      if contest.response_winner
        designer = contest.response_winner.designer
        statement = link_to(full_user_name(designer), admin_designer_path(designer))
        statement = statement + formatted_date(', won at ', contest.response_winner.won_at)
        statement.html_safe
      end
    end

    def promocode_details(contest, detail)
      codes = contest.contest_promocodes
      codes.first.promocode.send(detail) if codes.present?
    end
  end

end
