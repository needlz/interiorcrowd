module ActiveAdminExtensions

  module ContestDetails
    def last_contest_status(user)
      contest = user.last_contest
      return '' unless contest
      if contest.status == 'incomplete'
        ContestShortDetails.new(contest).progress
      else
        contest.status
      end
    end

    def end_date(contest)
      if %w[finished closed].include? contest.status
        formatted_date(contest.status.to_s.capitalize + ' at ', contest.finished_at)
      end
    end

    def contest_name(contest)
      client = contest.client
      full_contest_name =
        if controller.plain
          full_user_name(client).possessive + append_project_name(contest)
        else
          link_to(full_user_name(client).possessive, admin_client_path(client)) + append_project_name(contest)
        end
      full_contest_name.html_safe
    end

    def full_user_name(user)
      return user.first_name.to_s unless user.last_name
      return user.last_name.to_s unless user.first_name
      user.name
    end

    def append_project_name(contest)
      ' ' + contest.project_name.to_s + " (##{contest.id})"
    end

    def designers_list(requests)
     designers =
         requests.map do |request|
          designer = request.designer
          statement =
            if controller.plain
              full_user_name(designer)
            else
              link_to(full_user_name(designer), admin_designer_path(designer))
            end
          statement = yield(statement, request.submitted_at) if block_given?
          statement
        end
      if controller.plain
        designers.join("\n")
      else
        designers.join('<br />').html_safe
      end
    end

    def formatted_date(status_prefix, date)
      status_prefix + date.to_s
    end

    def winner_info(contest)
      if contest.response_winner
        designer = contest.response_winner.designer
        statement =
            if controller.plain
              full_user_name(designer)
            else
              link_to(full_user_name(designer), admin_designer_path(designer))
            end
        statement = statement + formatted_date(', won at ', contest.response_winner.won_at)
        statement.html_safe
      end
    end

    def promocode_details(contest, detail)
      codes = contest.contest_promocodes
      codes.first.promocode.try(detail) if codes.present?
    end
  end

end
